#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"
exit_non_zero_unless_installed docker
export $(echo_env_vars)

curl_smoke_test()
{
  echo curl log is in $(log_filename)
  rm -rf $(log_filename) || true

  echo
  curl_text_body_200 alive
  curl_text_body_200 ready
  curl_text_body_200 sha
  echo
  curl_text_body_200 /assets/app.css
  curl_text_body_200 /assets/app.js
}

curl_text()
{
  local -r route="${1}"  # eg ready
  curl  \
    --data '' \
    --fail \
    --request GET \
    --silent \
    --verbose \
      "http://localhost:$(server_port)/${route}" \
      > "$(log_filename)" 2>&1
}

curl_text_body_200()
{
  local -r route="${1}"  # eg ready
  if curl_text "${route}" && grep --quiet 200 "$(log_filename)"; then
    local -r result=$(tail -n 1 "$(log_filename)" | cut -b1-40)
    echo -e "SUCCESS: GET ${route}\t|${result}"
  else
    echo "FAILED: GET ${route}"
    cat "$(log_filename)"
    exit_non_zero
  fi
}

log_filename() { echo -n /tmp/asset_builder.log; }

demo()
{
  docker compose build --build-arg COMMIT_SHA="${COMMIT_SHA}" asset_builder
  docker compose --progress=plain up --detach --no-build --wait --wait-timeout=10 asset_builder
  curl_smoke_test
}

demo "$@"
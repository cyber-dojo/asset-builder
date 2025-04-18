#!/usr/bin/env bash
set -Eeu

readonly my_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly tmp_dir=$(mktemp -d "/tmp/asset_builder.XXX")
remove_tmp_dir() { rm -rf "${tmp_dir}" > /dev/null; }
trap remove_tmp_dir INT EXIT

source "${my_dir}/../bin/lib.sh"
exit_non_zero_unless_installed docker curl
export $(echo_env_vars)

docker compose build --build-arg COMMIT_SHA="${COMMIT_SHA}" asset_builder
docker compose --progress=plain up --detach --no-build --wait --wait-timeout=10 asset_builder

echo
for test_file in ${my_dir}/test_*; do
  ${test_file}
done

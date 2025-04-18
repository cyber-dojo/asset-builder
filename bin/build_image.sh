#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"
exit_non_zero_unless_installed docker
export $(echo_env_vars)

build_image()
{
  echo "Building..."
  echo "COMMIT_SHA=${COMMIT_SHA}"
  docker compose build asset_builder

  local -r image_name="${CYBER_DOJO_ASSET_BUILDER_IMAGE}:${CYBER_DOJO_ASSET_BUILDER_TAG}"
  local -r sha_in_image=$(docker run --rm --entrypoint="" "${image_name}" sh -c 'echo -n ${SHA}')
  if [ "${COMMIT_SHA}" != "${sha_in_image}" ]; then
    echo "ERROR: unexpected env-var inside image ${image_name}"
    echo "expected: 'SHA=${COMMIT_SHA}'"
    echo "  actual: 'SHA=${sha_in_image}'"
    exit 42
  fi
}

build_image "$@"
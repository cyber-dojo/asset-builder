#!/usr/bin/env bash
set -Eeu

echo_env_vars()
{
  # Set env-vars for this repo
  if [[ ! -v COMMIT_SHA ]] ; then
    echo COMMIT_SHA="$(image_sha)"  # --build-arg
  fi

  echo CYBER_DOJO_ASSET_BUILDER_SHA="$(image_sha)"
  echo CYBER_DOJO_ASSET_BUILDER_TAG="$(image_tag)"
  cat "$(repo_root)/.env"
}

image_sha()
{
  git rev-parse HEAD
}

repo_root()
{
  git rev-parse --show-toplevel
}

image_tag()
{
  local -r sha="$(image_sha)"
  echo "${sha:0:7}"
}

exit_non_zero_unless_installed()
{
  for dependent in "$@"
  do
    if ! installed "${dependent}" ; then
      stderr "${dependent} is not installed!"
      exit_non_zero
    fi
  done
}

# Ends the script, non-zero. Not kill -INT $$: a signal is a request, and
# test/run_tests.sh and bin/make_expected.sh trap INT to remove a temp dir.
# Those handlers do not exit, so bash ran the handler and then carried on from
# the next statement - a guard reporting a problem left the script running and
# exiting 0. exit cannot be declined; the EXIT trap still runs the cleanup.
exit_non_zero()
{
  exit 42
}

installed()
{
  if hash "${1}" &> /dev/null; then
    true
  else
    false
  fi
}

stderr()
{
  local -r message="${1}"
  >&2 echo "ERROR: ${message}"
}

server_port() { echo "${CYBER_DOJO_ASSET_BUILDER_PORT}"; }

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

# Keeps :latest and this commit's tag, which names the build just made. Every
# older tag goes, and an earlier build whose last tag was one of those goes
# with it, so local builds stop accumulating images.
#
# Note this also removes the tag web/Dockerfile and dashboard/Dockerfile pin in
# their 'FROM cyberdojo/asset_builder:<sha> AS assets' line, once that sha is no
# longer the current one. Their next build re-pulls it from dockerhub.
remove_old_images()
{
  local -r name="${CYBER_DOJO_ASSET_BUILDER_IMAGE}"
  local -r tag="${CYBER_DOJO_ASSET_BUILDER_TAG}"
  echo Removing old images
  # grep exits non-zero when the machine holds no asset_builder image, eg one
  # whose images have just been cleared, so an empty list must not end the build.
  local tagged_name
  for tagged_name in $(docker image ls --format '{{.Repository}}:{{.Tag}}' | grep "^${name}:" || true)
  do
    if [ "${tagged_name}" != "${name}:latest" ] \
    && [ "${tagged_name}" != "${name}:${tag}" ]; then
      # Removing by name:tag untags, so this succeeds even while a container
      # references the image, leaving it dangling until that container goes.
      docker image rm --force "${tagged_name}" || echo "  skipped ${tagged_name} (in use)"
    fi
  done
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

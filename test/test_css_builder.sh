#!/usr/bin/env bash

readonly my_dir="$(cd "$(dirname "${0}")" && pwd)"
source "${my_dir}/../bin/lib.sh"
exit_non_zero_unless_installed curl
export $(echo_env_vars)

test_SUCCESS_css_builder() { :; }

test___SUCCESS_example_with_volume_mount()
{
  local -r expected="$(cat "${my_dir}/expected/app.css")"
  local -r actual="$(curl --silent http://localhost:$(server_port)/assets/app.css)"
  assertEquals "" "${expected}" "${actual}"
}

echo "::${0##*/}"
. ${my_dir}/shunit2_helpers.sh
. ${my_dir}/shunit2


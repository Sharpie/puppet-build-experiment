#!/bin/bash

print_usage() {
  cat <<EOF
USAGE: ./component-version.sh <project> <project version> <component>

Retrieves the version of a Vanagon build component. Only works
for components that store version numbers in .json files.

Example:

  # Retrieve Facter version used by puppet-agent 6.13.0
  ./component-version puppet-agent 6.13.0 facter
EOF
}

check_dependencies() {
  local cmds
  cmds=('curl' 'jq')

  for c in "${cmds[@]}"; do
    command -v "${c}" >/dev/null || {
      printf 'This script requires "%s" to be on the PATH.\n' "${c}"
      exit 1
    }
  done
}


while getopts h flag; do
  case "${flag}" in
    h)
      print_usage
      exit 0
      ;;
    ?)
      print_usage >&2
      exit 1
      ;;
  esac
done

if [[ $# -ne 3 ]]; then
  print_usage >&2
  printf 'This script requires 3 arguments!\n' >&2
  exit 1
fi

check_dependencies

component_url="https://raw.githubusercontent.com/puppetlabs/${1}/${2}/configs/components/${3}.json"
component_data=$(curl -fsSL "${component_url}")
if [[ $? -ne 0 ]]; then
  printf 'Could not retrieve component data from:\n\t%s\n' "${component_url}" >&2
  exit 1
fi

version=$(jq -er '.version // .ref' <(printf '%s' "${component_data}"))
if [[ $? -ne 0 ]]; then
  printf 'Could not parse a "version" or "ref" field from:\n\t%s\n' "${component_data}" >&2
  exit 1
fi

# In case the ref field has something like refs/tags/<version>
basename "${version}"

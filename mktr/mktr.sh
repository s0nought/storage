#!/bin/bash

# make time report

_script_name="${0##*/}"
_script_version="2022.07.30"

_script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

_python_script_path="${_script_dir}/mktr.py"

if [[ $# -eq 0 || "$1" = "" || "$1" =~ [[:space:]] ]]; then
    echo "Expected 1 argument, got $#"
    exit 1
fi

_target_dir="$1"

pushd "${_target_dir}" >/dev/null

for _file_path in $(find . -name *.md -printf '%p\n'); do
    _file_name="${_file_path##*/}"
    python3 "${_python_script_path}" "${_file_name}" "${_file_path}" "${_script_dir}"
done

popd >/dev/null

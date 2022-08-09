#!/bin/bash

# make report file

_script_name="${0##*/}"
_script_version="2022.08.09"

_file_name=$(date "+%Y.%m.%d")
_dir_path="work/${_file_name//.//}"
_file_path="${_dir_path}/${_file_name}.md"

pushd ~/ >/dev/null

if [[ -r "${_file_path}" ]]; then
    open ${_file_path}
else
    mkdir -p "${_dir_path}"
    touch "${_file_path}"
fi

popd >/dev/null

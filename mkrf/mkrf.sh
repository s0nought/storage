#!/bin/bash

# make report file

_script_name="${0##*/}"
_script_version="2022.07.30"

_file_name=$(date "+%Y.%m.%d")
_dir_path="work/${_file_name//.//}"
_file_path="${_dir_path}/${_file_name}.md"

pushd ~/ >/dev/null

[[ -r "${_file_path}" ]] || \
    mkdir -p "${_dir_path}"
    touch "${_file_path}"

popd >/dev/null

#!/bin/bash

# make time report

_script_name="${0##*/}"
_script_version="2022.12.18"

_script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

_python_script_path="${_script_dir}/mktr.py"

if [[ $# -eq 0 || "$1" = "" || "$1" =~ [[:space:]] ]]; then
    echo "Expected 1 argument, got $#"
    exit 1
fi

_target_dir="$1"

_years="$(echo {2021..2022})"
_months="$(echo {01..12})"
_days="$(echo {01..31})"

_counter=0

for _year in ${_years}; do
    for _month in ${_months}; do
        for _day in ${_days}; do
            _file_name="${_year}.${_month}.${_day}.md"
            _file_path="${_target_dir}/${_year}/${_month}/${_day}/${_file_name}"

            if [[ -f "${_file_path}" ]]; then
                python3 "${_python_script_path}" "${_file_name}" "${_file_path}" "${_script_dir}"

                ((_counter++))
            fi
        done
    done
done

echo "Files found: ${_counter}"
echo "Done."

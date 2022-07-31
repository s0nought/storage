#!/bin/bash

_action="" # is $1 if $1 !== -h|--help|-v|--version

# /home/s0nought/prunc.sh
_env_var_name="${0##*/}" # -> prunc.sh
_script_name="${_env_var_name}"

_env_var_name="${_env_var_name%.*}_prefix" # -> prunc_prefix

_env_var_value="${!_env_var_name}"

_script_version="version 1.1 (October, 2021)"

_syntax="
${_script_name}   ${_script_version}
Manage PTS/PNTS services with one-liners

Usage:
  ${_script_name} <command> [prefix]

Where:
  'command' will be executed once for each of the services
  'prefix' is the prefix of the services to execute the command against

Supported commands:
  -h, --help         Display help and exit
  -v, --version      Display version and exit
  sa, sta, start     Execute command 'start'
  so, sto, stop      Execute command 'stop'
  rr, res, restart   Execute command 'restart'
  ss, status         Execute command 'status'

Example:
  ${_script_name} -h
  ${_script_name} rr
  ${_script_name} rr pnts22

Supported working modes:
  1) Manual
     Specify both the command and the prefix.
     Example: ${_script_name} rr pnts22

  2) Predefined prefix
     Specify the command only.
     Example: ${_script_name} rr
     
     The environment variable '${_env_var_name}' must be created beforehand.
     To create the variable run: export ${_env_var_name}=<prefix>

  3) Select the prefix
     Specify the command only.
     Example: ${_script_name} rr

     The environment variable '${_env_var_name}' must not exist.
     The program will attempt to define a list of available prefixes.
     If any, a menu to select the prefix will be displayed.

Notes:
  Working mode #3 makes use of the list of hardcoded prefixes.
  The list of postfixes for PTS/PNTS services is also hardcoded.

Written by s0nought
https://github.com/s0nought
"

_syntax_err_msg='The syntax of the command is incorrect.'

# order: newest to oldest
_prefixes=(\
    'pnts' \
    'ptsu' \
    'pasu' \
    'promt' \
)

# order: unordered
_postfixes=(\
    '-balancer.service' \
    '-dcs.service' \
    '-managed.service' \
    '-nginx.service' \
    '-translator.service' \
    '-analyzer.service' \
    '-smt.service' \
)

function show_msg() {
    echo "$*"
    exit 0
}

function err() {
    echo "$*"
    exit 1
}

if [[ $# -eq 0 || "$1" =~ [[:space:]] ]]; then
    err "${_syntax_err_msg}" "At least one argument is required."
fi

case "$1" in
    (-h | --help) \
        show_msg "${_syntax}";;
    
    (-v | --version) \
        show_msg "${_script_version}";;
esac

sudo systemctl --version >/dev/null 2>/dev/null; _systemctl_exit_code=$?

if [[ ${_systemctl_exit_code} -ne 0 ]]; then
    err "systemctl is required to run this program but cannot be found."
fi

function run_commands() {
    local _action="$1"
    local _prefix="$2"

    echo -e "Running commands...\n  action: ${_action}\n  prefix: ${_prefix}"

    for _postfix in "${_postfixes[@]}"; do # array is hardcoded
        _service_name="${_prefix}${_postfix}"

        echo -n "         ${_service_name}"

        if [[ -e "/etc/systemd/system/${_service_name}" ]]; then
            sudo systemctl ${_action} ${_service_name} \
            && echo -e -n "\r  [ OK ] ${_service_name}\n" \
            || echo -e -n "\r  [FAIL] ${_service_name}\n"
        else
            echo -e -n "\r  [!FND] ${_service_name} (not found)\n"
        fi
    done
}

function get_prefixes() {
    pushd "/etc/systemd/system" >/dev/null

    local _found_prefixes=()

    echo "Attempting to auto-detect the prefixes..."
    echo -n "  searching: "
    for _prefix in "${_prefixes[@]}"; do # array is hardcoded

        echo -n "${_prefix} " # appends to '  searching: '
        for _match in ${_prefix}*balancer.service; do
            if [[ -e "${_match}" ]]; then
                _match="${_match##*/}"
                _match="${_match%-balancer*}"
                _found_prefixes+=("${_match}") # prefix + version; e.g. pnts22
            fi
        done

    done

    popd >/dev/null

    if [[ ${#_found_prefixes} -eq 0 ]]; then
        echo -e "\n  nothing found." # new line is for `echo -n "${_prefix} "`
        return
    fi

    new_menu "${_found_prefixes[@]}"
}

function new_menu() {
    echo -e "\n  choose a service group to [${_action}]:"

    IFS=' ' read -r -a _options <<< "$*"
    _options+=("exit")
    _options_len=${#_options[@]}

    select _prefix in "${_options[@]}"; do
        case "${_prefix}" in
            (exit) \
                show_msg "The operation was cancelled by the user.";;

            (*) \
                if [[ $REPLY -eq 0 || $REPLY -gt ${_options_len} ]]; then
                    echo "  choose a number from 1 to ${_options_len}"
                fi

                if [[ $REPLY -gt 0 && $REPLY -le ${_options_len} ]]; then
                    run_commands "${_action}" "${_prefix}" # _action is global
                    break;
                fi;;
        esac
    done
}

case "$1" in
    (sa | sta | start) \
        _action="start";;

    (so | sto | stop) \
        _action="stop";;

    (rr | res | restart) \
        _action="restart";;

    (ss | status) \
        _action="status";;

    (*) \
        err "${_syntax_err_msg}" "Unknown argument '$1'.";;
esac

if [[ $# -ge 2 ]]; then
    run_commands "${_action}" "$2"
    show_msg "Done."
fi

if [[ $# -eq 1 && -n "${_env_var_value}" ]]; then
    run_commands "${_action}" "${_env_var_value}"
    show_msg "Done."
fi

if [[ $# -eq 1 && -z "${_env_var_value}" ]]; then
    get_prefixes # if any, executes new_menu() which executes run_commands()
    show_msg "Done."
fi

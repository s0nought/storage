#!/bin/bash

# get interactive TTY

_favourite_namespaces=(\
    'kube-public' \
    'kube-system' \
    #'add-your-favourites-here' \
)

# Changelog:
# 
# 2022.07.30 - version 1
# 2022.08.01 - version 2
#     - fixed a bug where when kubectl is installed, the script will exit with code 1
#     - fixed a bug where when there is just one match for a namespace or pod, awk will trim it out
#     - made namespace and pod search case-insensitive

_script_name="${0##*/}"
_script_version="2022.08.01"

_syntax="
${_script_name}   ${_script_version}

Get an interactive TTY from a container of a pod."

case "$1" in
    ('-h' | '--help') \
        echo "${_syntax}"
        exit 0;;
esac

_test_kubectl_installed=$(kubectl version --client 2>/dev/null)

if [[ $? -gt 0 ]]; then
    echo "kubectl not found"
    exit 1
fi

_user_choice_select=""
_user_choice_prompt=""
_select_options=()

_namespace=""
_pod_name=""
_destination=""

function get_user_choice() {
    _user_choice_select=""
    __options=("$@") # accumulate passed arguments in the array

    select __option in "${__options[@]}"; do
        if [[ -n "${__option}" ]]; then
            _user_choice_select="${__option}"
            break;
        else
            echo "Select one of the options above or press Control-C to exit."
        fi
    done
}

function get_user_prompt() {
    _user_choice_prompt=""

    while [[ -z "${_user_choice_prompt}" ]]; do
        echo -n "Enter $1 and press [ENTER]: "
        read _user_choice_prompt
    done
}

function convert_to_array() {
    # converts a string to an array (delimeter: space)

    _select_options=()

    IFS=' '
    read -r -a _select_options <<< "$*"
}

function get_namespaces() {
    __namespaces="$(kubectl get namespace | grep -iF "$1" | awk '{ print $1 }')"
    convert_to_array "${__namespaces}"
}

function get_pods() {
    __pods="$(kubectl get pods -n "$1" | grep -iF "$2" | awk '{ print $1 }')"
    convert_to_array "${__pods}"
}

##########################################

echo "--- Namespace ---"

_step_namespace_options=(\
    'select from favourites' \
    'find by name' \
)

get_user_choice "${_step_namespace_options[@]}"

case "${_user_choice_select}" in
    ('select from favourites') \
        if [[ ${#_favourite_namespaces[@]} -eq 0 ]]; then
            echo "Favourites not found. Exiting..."
            exit 0
        else
            get_user_choice "${_favourite_namespaces[@]}"
        fi;;

    ('find by name') \
        while [[ ${#_select_options[@]} -eq 0 ]]; do
            get_user_prompt "search query"
            get_namespaces "${_user_choice_prompt}"
            if [[ ${#_select_options[@]} -eq 0 ]]; then
                echo "Nothing found. Try another search query"
            fi
        done
        get_user_choice "${_select_options[@]}";;
esac

_namespace="${_user_choice_select}"

##########################################

echo "--- Pod name ---"

_step_pod_name_options=(\
    'le-pod' \
    #'add-your-favourites-here' \
    'find by name' \
)

get_user_choice "${_step_pod_name_options[@]}"

case "${_user_choice_select}" in
    ('find by name') \
        while [[ ${#_select_options[@]} -eq 0 ]]; do
            get_user_prompt "search query"
            get_pods "${_namespace}" "${_user_choice_prompt}"
            if [[ ${#_select_options[@]} -eq 0 ]]; then
                echo "Nothing found. Try a different search query"
            fi
        done
        get_user_choice "${_select_options[@]}";;
esac

_pod_name="${_user_choice_select}"

##########################################

echo "--- Destination ---"

_step_destination_options=(\
    '/bin/bash' \
    'rails c' \
    #'add-your-favourites-here' \
)

get_user_choice "${_step_destination_options[@]}"

_destination="${_user_choice_select}"

##########################################

kubectl exec -n ${_namespace} \
-i -t -c puma ${_pod_name} \
-- /vault/vault-env "${_destination}"

# -*- mode: sh; sh-shell: bash; -*-
# shellcheck shell=bash

# MIT license (c) 2021 https://github.com/slowpeek
# Homepage: https://github.com/slowpeek/here-bye

_ () {
    IFS=, read -r -a HERE_PREFIX <<< "${HERE_PREFIX-}"
    IFS=, read -r -a BYE_PREFIX <<< "${BYE_PREFIX-}"

    declare -g +x HERE_PREFIX BYE_PREFIX

    # shellcheck disable=SC2034
    declare -g -A HERE_WRAP=([bye]=t [here2]=t)
}; _; unset -f _

here () {
    local _IFS=$IFS
    IFS=' '

    local auto=n
    if (($# > 0)); then
        local el prefix=

        for el in "${HERE_PREFIX[@]}"; do
            [[ ! $el == auto ]] || auto=y
            prefix+="[$el]"
        done

        [[ -z $prefix ]] || prefix+=' '
    fi

    local ctl=0
    [[ ${HERE_VERBOSE-} == y ]] && ctl=-1 || [[ $auto == n ]] || ctl=1

    if ((ctl)); then
        local n=${#FUNCNAME[@]} i=1

        # Step over known wrappers.
        while [[ -v HERE_WRAP[${FUNCNAME[i]}] ]]; do
            if ((++i >= n)); then
                # The config seems messed up since everything is a
                # wrapper. Ignore it.
                i=1
                break
            fi
        done

        local stack=() s

        for ((; ctl && i<n; ctl--, i++)); do
            s=${BASH_SOURCE[i]}:${BASH_LINENO[i-1]}
            ((i >= n-1)) || [[ ${FUNCNAME[i]} == source ]] ||
                s+=" ${FUNCNAME[i]}"
            stack+=("$s")
        done

        [[ $auto == n ]] || prefix=${prefix//'[auto]'/"[${stack[0]}]"}
    fi

    (($# == 0)) || printf "%s%s\n" "$prefix" "$*"

    if ((ctl < 0)); then
        echo -e '\nCall stack:'
        printf '%s\n' "${stack[@]}"
    fi

    IFS=$_IFS
}

here2 () {
    here "$@" >&2
}

bye () {
    [[ ! ${BYE_VERBOSE-} == y ]] || HERE_VERBOSE=y
    HERE_PREFIX=("${BYE_PREFIX[@]}" "${HERE_PREFIX[@]}")

    here "$@" >&2
    exit "${BYE_EXIT:-1}"
}

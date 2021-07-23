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
    local _IFS=$IFS parent lvl=${#FUNCNAME[@]}
    IFS=' '

    # Step over known wrappers.
    local i=1
    while [[ -v HERE_WRAP[${FUNCNAME[i]}] ]]; do
        if ((++i >= lvl)); then
            # The config seems messed up since everything is a
            # wrapper. Ignore it.
            i=1
            break
        fi
    done

    ((parent = i-1, lvl -= parent))

    local lineno func file

    if (($# > 0)); then     # Only print not empty messages.
        local el prefix=

        for el in "${HERE_PREFIX[@]}"; do
            if [[ $el == auto ]]; then
                read -r lineno func file < <(caller "$parent")
                el=$file:$lineno
                ((lvl <= 2)) || el+=" $func"
            fi

            prefix+="[$el]"
        done

        [[ -z $prefix ]] || prefix+=' '

        printf "%s%s\n" "$prefix" "$*"
    fi

    if [[ ${HERE_VERBOSE-} == y ]]; then
        local s n=$parent stack=()
        while s=$(caller "$n"); do
            read -r lineno func file <<< "$s"
            ((++n))
            stack+=("$file:$lineno $func")
        done

        stack[-1]=${stack[-1]% main}

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

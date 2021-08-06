# -*- mode: sh; sh-shell: bash; -*-
# shellcheck shell=bash

# MIT license (c) 2021 https://github.com/slowpeek
# Homepage: https://github.com/slowpeek/here-bye

_ () {
    IFS=, read -r -a HERE_PREFIX <<< "${HERE_PREFIX-}"
    IFS=, read -r -a BYE_PREFIX <<< "${BYE_PREFIX-}"

    # shellcheck disable=SC2034
    declare -g -A HERE_WRAP=([bye]=t [here2]=t)
}; _; unset -f _

here () {
    local auto=n
    if (($# > 0)); then
        local el prefix=

        for el in ${HERE_PREFIX[@]+"${HERE_PREFIX[@]}"}; do
            [[ ! $el == auto ]] || auto=y
            prefix+="[$el]"
        done

        [[ -z $prefix ]] || prefix+=' '
    fi

    local ctl=0
    [[ ${HERE_CONTEXT-} == y ]] && ctl=-1 || [[ $auto == n ]] || ctl=1

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

        local context=() s

        for ((; ctl && i<n; ctl--, i++)); do
            s=${BASH_SOURCE[i]}:${BASH_LINENO[i-1]}
            ((i >= n-1)) || [[ ${FUNCNAME[i]} == source ]] ||
                s+=" ${FUNCNAME[i]}"
            context+=("$s")
        done

        [[ $auto == n ]] || prefix=${prefix//'[auto]'/"[${context[0]}]"}
    fi

    if (($# > 0)); then
        local IFS=' '
        printf "%s%s\n" "$prefix" "$*"
    fi

    if ((ctl < 0)); then
        echo -e '\n--- context ---'
        printf '%s\n' "${context[@]}"
        echo -e '---\n'
    fi
}

here2 () {
    here "$@" >&2
}

bye () {
    [[ ! ${BYE_CONTEXT-} == y ]] || HERE_CONTEXT=y

    if [[ -v BYE_PREFIX ]]; then
        HERE_PREFIX=(
            "${BYE_PREFIX[@]}"
            ${HERE_PREFIX[@]+"${HERE_PREFIX[@]}"}
        )
    fi

    here "$@" >&2
    exit "${BYE_EXIT:-1}"
}

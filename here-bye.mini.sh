# -*- mode: sh; sh-shell: bash; -*-
# shellcheck shell=bash

# MIT license (c) 2021 https://github.com/slowpeek
# Homepage: https://github.com/slowpeek/here-bye

_ () {
    IFS=, read -r -a HERE_PREFIX <<< "${HERE_PREFIX-}"
    IFS=, read -r -a BYE_PREFIX <<< "${BYE_PREFIX-}"
}; _; unset -f _

here () {
    if (($# > 0)); then
        if [[ -v HERE_PREFIX ]]; then
            printf '[%s]' "${HERE_PREFIX[@]}"
            echo -n ' '
        fi

        local IFS=' '
        printf '%s\n' "$*"
    fi
}

here2 () {
    here "$@" >&2
}

bye () {
    HERE_PREFIX=("${BYE_PREFIX[@]}" "${HERE_PREFIX[@]}")

    here "$@" >&2
    exit "${BYE_EXIT:-1}"
}

# -*- mode: sh; sh-shell: bash; -*-
# shellcheck shell=bash

# MIT license (c) 2021 https://github.com/slowpeek
# Homepage: https://github.com/slowpeek/here-bye

here () {
    local IFS=' '
    printf '%s\n' "$*"
}

here2 () {
    here "$@" >&2
}

bye () {
    here "$@" >&2
    exit "${BYE_EXIT:-1}"
}

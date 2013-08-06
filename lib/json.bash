# json.bash - JSON Loader/Dumper for Bash
#
# Copyright (c) 2013 Ingy döt Net

JSON_VERSION=0.0.1

#-----------------------------------------------------------------------------
# API functions
#-----------------------------------------------------------------------------
JSON.load() {
    unset JSON__cache
    set -e -o pipefail
    case $# in
        0) JSON.lex | JSON.lex | JSON.parse ;;
        1) JSON__cache=$(echo -E "$1" | JSON.lex | JSON.parse) ;;
        2)
            local temp=$(echo -E "$1" | JSON.lex | JSON.parse)
            declare -g $2="$temp"
            ;;
        *) JSON.die 'Usage: JSON.load [<json-string> [<tree-var>]]' ;;
    esac
}

JSON.dump() {
    JSON.die 'JSON.dump not yet implemented.'
    set -e -o pipefail
    case $# in
        0)
            JSON.normalize | sort | JSON.emit-json
            ;;
        1)
            if [ "$1" == '-' ]; then
                echo "$JSON__cache" | JSON.dump-json
            else
                echo ${!1} | JSON.dump-json
            fi
            ;;
        *) JSON.die 'Usage: JSON.dump [<tree-var>]' ;;
    esac
}

JSON.get() {
    set -e -o pipefail
    if [[ $# -gt 0 ]] && [[ "$1" =~ ^-([snbz])$ ]]; then
        local flag="${BASH_REMATCH[1]}"
        shift
    fi
    case $# in
        1)
            grep -Em1 "^$1	" | cut -f2
            ;;
        2)
            if [ "$1" == '-' ]; then
                echo "$JSON__cache" | grep -Em1 "^$1	" | cut -f2
            else
                case $flag in
                    s)
                        echo "${!2}" |
                            grep -Em1 "^$1	" |
                            cut -f2 |
                            perl -pe 's/^"(.*)"$/$1/ or die "JSON.get -s flag used and value not a string\n"'
                        ;;
                    *)
                        echo "\"${!2}\"" |
                            grep -Em1 "^$1	" |
                            cut -f2
                        ;;
                esac
            fi
            ;;
        *) JSON.die 'Usage: JSON.get [-s|-n|-b|-z] <key-path> [<tree-var>]' ;;
    esac
}

JSON.put() {
    set -e -o pipefail
    if [[ $# -gt 0 ]] && [[ "$1" =~ ^-([snbz])$ ]]; then
        local flag="${BASH_REMATCH[1]}"
        shift
    fi
    case $# in
        2)
            JSON.del "$1"
            printf "$1\t$2\n"
            ;;
        3)
            if [ "$1" == '-' ]; then
                echo "$JSON__cache" | JSON.del "$1"
                printf "$1\t$2\n"
            else
                echo ${!3} | JSON.del "$1"
                printf "$1\t$2\n"
            fi
            ;;
        *) JSON.die 'Usage: JSON.put [-s|-n|-b|-z] <key-path> <new-value> [<tree-var>]' ;;
    esac
}

JSON.del() {
    set -e -o pipefail
    case $# in
        1)
            grep -Ev "$1	"
            ;;
        2)
            if [ "$1" == '-' ]; then
                echo "$JSON__cache" | grep -Ev "$1	"
            else
                echo ${!1} | grep -Ev "$1	"
            fi
            ;;
        *) JSON.die 'Usage: JSON.get [-s|-n|-b|-z] <key-path> [<tree-var>]' ;;
    esac
}

JSON.cache() {
    set -e -o pipefail
    case $# in
        0)
            echo "$JSON__cache"
            ;;
        1)
            printf -v "$1" "%s" "$JSON__cache"
            ;;
        *) JSON.die 'Usage: JSON.cache [<tree-var>]' ;;
    esac
}

#-----------------------------------------------------------------------------
JSON_CHR='[^"\\[:cntrl:]]'
JSON_ESC='(\\["\\/bfnrt]|\\u[0-9a-fA-F]{4})'
JSON_STR="\"($JSON_CHR|$JSON_ESC)*\""
JSON_NUM='-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?'
JSON_BOOL='null|false|true'
JSON_SPACE='[[:space:]]+'
JSON_PUNCT='[][{}:,]'
JSON_OTHER='.'
JSON_SCALAR="^($JSON_STR|$JSON_NUM|$JSON_BOOL)$"
JSON_TOKEN="$JSON_STR|$JSON_NUM|$JSON_BOOL|$JSON_PUNCT|$JSON_SPACE|$JSON_OTHER"

JSON.lex() {
    local GREP_COLORS GREP_COLOR
    \grep -Eo "$JSON_TOKEN" | \grep -Ev "^$JSON_SPACE$"
}

JSON.parse() {
    read -r JSON_token
    case "$JSON_token" in
        '{') JSON.parse-object '' ;;
        '[') JSON.parse-array '' ;;
        *) JSON.parse-error "'{' or '['";;
    esac
}

JSON.parse-object() {
    read -r JSON_token
    while [ $JSON_token != '}' ]; do
        [[ $JSON_token =~ ^\" ]] || JSON.parse-error STRING
        local key="${JSON_token:1:$((${#JSON_token}-2))}"
        read -r JSON_token
        [ $JSON_token == ':' ] || JSON.parse-error "':'"
        read -r JSON_token
        JSON.parse-value "$1/$key"
        read -r JSON_token
        if [ $JSON_token == ',' ]; then
            read -r JSON_token
        else
            [ $JSON_token == '}' ] || JSON.parse-error "'}'"
        fi
    done
}

JSON.parse-array() {
    local index=0
    read -r JSON_token
    while [ $JSON_token != ']' ]; do
        JSON.parse-value "$1/$((index++))"
        read -r JSON_token
        if [ $JSON_token == ',' ]; then
            read -r JSON_token
        else
            [ $JSON_token == ']' ] || JSON.parse-error "']'"
        fi
    done
}

JSON.parse-value() {
    case "$JSON_token" in
        '[') JSON.parse-array "$1";;
        '{') JSON.parse-object "$1";;
        *)
            [[ "$JSON_token" =~ $JSON_SCALAR ]] ||
                JSON.parse-error
            printf "%s\t%s\n" "$1" "$JSON_token"
    esac
}

JSON.parse-error() {
    msg="JSON.parse error. Unexpected token: '$JSON_token'."
    [ -n "$1" ] && msg+=" Expected: $1."
    JSON.die "$msg"
}

JSON.assert-cache() {
    [ -n "$JSON__cache" ] || JSON.die 'JSON.get error: no cached data.'
}

JSON.die() {
    echo "$*" >&2
    exit 1
}

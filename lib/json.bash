# json.bash - JSON Loader/Dumper for Bash
#
# Copyright (c) 2013-2016 Ingy döt Net

JSON_VERSION=0.0.2

#-----------------------------------------------------------------------------
# API functions
#-----------------------------------------------------------------------------
JSON.load() {
  unset JSON__cache
  case $# in
    0) (set -o pipefail; JSON.lex | JSON.parse) ;;
    1) JSON__cache="$(set -o pipefail; echo -E "$1" | JSON.lex | JSON.parse)"
      [[ -n $JSON__cache ]] && JSON__cache+=$'\n'
      ;;
    2) printf -v "$2" "%s" "$(echo -E "$1" | JSON.lex | JSON.parse)"
      [[ -n ${!2} ]] && printf -v "$2" "%s\n" "${!2}"
      ;;
    *) JSON.die 'Usage: JSON.load [<json-string> [<tree-var>]]' ;;
  esac
  :
}


JSON.style() {
  local style="${1:?Style type is required}"
  local indent='  '
  [[ $# -eq 1 ]] || indent="$2"

  case "$style" in
    minimal)
      JSON_INDENT=""
      JSON_FIELD_SEP=","
      JSON_KEY_SEP=":"
      JSON_ARR_BEGIN="["
      JSON_ARR_END="]"
      JSON_OBJ_BEGIN="{"
      JSON_OBJ_END="}"
      ;;
    normal)
      JSON_INDENT=""
      JSON_FIELD_SEP=", "
      JSON_KEY_SEP=": "
      JSON_ARR_BEGIN="["
      JSON_ARR_END="]"
      JSON_OBJ_BEGIN="{"
      JSON_OBJ_END="}"
      ;;
    pretty)
      JSON_INDENT="$indent"
      JSON_FIELD_SEP=$',\n'
      JSON_KEY_SEP=": "
      JSON_ARR_BEGIN=$'[\n'
      JSON_ARR_END=$'\nINDENT]'
      JSON_OBJ_BEGIN=$'{\n'
      JSON_OBJ_END=$'\nINDENT}'
      ;;
    *) JSON.die 'Usage: JSON.style minimal|normal|pretty [<indent-string>]' ;;
    esac
}
JSON.style normal

JSON.dump() {
  set -o pipefail
  case $# in
    0)
      JSON._dump
      ;;
    1)
      if [[ $1 == '-' ]]; then
        echo "$JSON__cache" | JSON.dump
      else
        echo "${!1}" | JSON.dump
      fi
      ;;
    *) JSON.die 'Usage: JSON.dump [<tree-var>]' ;;
  esac
}

JSON._indent() {
    [ "$1" -le 0 ] || printf "$JSON_INDENT%.0s" $(seq 1 "$1")
}

JSON._dump() {
  local stack=()
  local prev=("/")
  local first=""
  while IFS=$'/\t' read -r -a line; do
    [ ${#line[@]} -gt 0 ] || continue
    last=$((${#line[@]}-1))
    val="${line[$last]}"
    unset line[$last]
    ((last--))
    for i in ${!line[@]}; do
      [ "${prev[$i]}" != "${line[$i]}" ] || continue
      while [ $i -lt ${#stack} ]; do
        local type="${stack:0:1}"
        stack="${stack:1}"
        if [ "$type" = "a" ]; then
          echo -n "${JSON_ARR_END//INDENT/$(JSON._indent ${#stack})}"
        else
          echo -n "${JSON_OBJ_END//INDENT/$(JSON._indent ${#stack})}"
        fi
      done
      if [ $i -gt 0 ]; then
        if [ -z "$first" ]; then
          echo -n "$JSON_FIELD_SEP"
        else
          first="";
        fi
        echo -n "$(JSON._indent ${#stack})"
        [ "${stack:0:1}" = "a" ] || echo -n "\"${line[$i]}\"$JSON_KEY_SEP"
      fi
      if [ $i -eq $last ]; then
        echo -n "$val"
      else
        if [[ "${line[((i+1))]}" =~ [0-9]+ ]]; then
          stack="a$stack";
          echo -n "$JSON_ARR_BEGIN"
        else
          stack="o$stack";
          echo -n "$JSON_OBJ_BEGIN"
        fi
        first="1"
      fi
    done
    prev=("${line[@]}")
  done < <(sed 's/\t/\n/;' |
    sed '1~2{;s|[0-9]\{1,\}|00000000000&|g;s|0*\([0-9]\{12,\}\)|\1|g;}' |
    paste - - |
    sort -k '1,1' -u)
  local indent=$(( ${#stack} - 1 ))
  for (( i=0; i<${#stack}; i++ )); do
    if [ "${stack:$i:1}" = "a" ]; then
      echo -n "${JSON_ARR_END//INDENT/$(JSON._indent $indent)}"
    else
      echo -n "${JSON_OBJ_END//INDENT/$(JSON._indent $indent)}"
    fi
    (( indent-- ))
  done
  echo
}

JSON.get() {
  local flag=""
  if [[ $# -gt 0 && $1 =~ ^-([asnbz])$ ]]; then
    flag="${BASH_REMATCH[1]}"
    shift
  fi
  case $# in
    1)
      grep -Em1 "^$1	" | cut -f2 |
          JSON.apply-get-flag "$flag"
      ;;
    2)
      if [[ $2 == '-' ]]; then
        echo "$JSON__cache" |
          grep -Em1 "^$1	" |
          cut -f2 |
          JSON.apply-get-flag "$flag"
      else
        echo "${!2}" |
          grep -Em1 "^$1	" |
          cut -f2 |
          JSON.apply-get-flag "$flag"
      fi
      ;;
    *) JSON.die 'Usage: JSON.get [-a|-s|-n|-b|-z] <key-path> [<tree-var>]' ;;
  esac
}

JSON.keys() {
  if [[ $# -gt 2 ]]; then
    JSON.die 'Usage: JSON.keys <key-path> [<tree-var>]'
  fi
  JSON.object "$@" |
    cut -f1 |
    sed "s/^\///; s/\/.*//" |
    sort -u
}

JSON.object() {
  case $# in
    1)
      JSON._object "$@"
      ;;
    2)
      if [ "$2" == '-' ]; then
        echo "$JSON__cache" | JSON._object "$@"
      else
        echo "${!2}" | JSON._object "$@"
      fi
      ;;
    *)
    JSON.die 'Usage: JSON.object <key-path> [<tree-var>]' ;;
  esac
}

JSON._object() {
  local key=$1
  if [[ -n $key && $key != "/" ]]; then
    key=${key//\//\\/}
    sed -n "s/^$key//p"
  else
    cat
  fi
}

JSON.put() {
  set -o pipefail
  if [[ $# -gt 0 && $1 =~ ^-([snbz])$ ]]; then
    local flag="${BASH_REMATCH[1]}"
    shift
  fi
  case $# in
    2)
      JSON.del "$1"
      printf "$1\t$2\n"
      ;;
    3)
      if [[ $1 == '-' ]]; then
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
  set -o pipefail
  case $# in
    1)
      grep -Ev "$1	"
      ;;
    2)
      if [[ $1 == '-' ]]; then
        echo "$JSON__cache" | grep -Ev "$1	"
      else
        echo ${!1} | grep -Ev "$1	"
      fi
      ;;
    *) JSON.die 'Usage: JSON.get [-s|-n|-b|-z] <key-path> [<tree-var>]' ;;
  esac
}

JSON.cache() {
  case $# in
    0)
      echo -n "$JSON__cache"
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
  while [[ $JSON_token != '}' ]]; do
    [[ $JSON_token =~ ^\" ]] || JSON.parse-error STRING   #"
    local key="${JSON_token:1:$((${#JSON_token}-2))}"
    read -r JSON_token
    [[ $JSON_token == ':' ]] || JSON.parse-error "':'"
    read -r JSON_token
    JSON.parse-value "$1/$key"
    read -r JSON_token
    if [[ $JSON_token == ',' ]]; then
      read -r JSON_token
    else
      [[ $JSON_token == '}' ]] || JSON.parse-error "'}'"
    fi
  done
}

JSON.parse-array() {
  local index=0
  read -r JSON_token
  while [[ $JSON_token != ']' ]]; do
    JSON.parse-value "$1/$((index++))"
    read -r JSON_token
    if [[ $JSON_token == ',' ]]; then
      read -r JSON_token
    else
      [[ $JSON_token == ']' ]] || JSON.parse-error "']'"
    fi
  done
}

JSON.parse-value() {
  case "$JSON_token" in
    '[') JSON.parse-array "$1";;
    '{') JSON.parse-object "$1";;
    *)
      [[ $JSON_token =~ $JSON_SCALAR ]] ||
        JSON.parse-error
      printf "%s\t%s\n" "$1" "$JSON_token"
  esac
}

JSON.parse-error() {
  msg="JSON.parse error. Unexpected token: '$JSON_token'."
  [[ -n $1 ]] && msg+=" Expected: $1."
  JSON.die "$msg"
}

JSON.apply-get-flag() {
  local value
  read -r value
  # For now assume null can show up instead of string or number
  if [[ $value == null ]]; then
    echo ''
    return 0
  fi
  case $1 in
    a)
      [[ $value =~ ^$JSON_STR$ ]] && {
        value="${value:1:$((${#value}-2))}"
      }
      ;;
    s)
      [[ $value =~ ^$JSON_STR$ ]] || {
        echo "JSON.get -s flag used but '$value' is not a string" >&2
        return 1
      }
      value="${value:1:$((${#value}-2))}"
      ;;
    n)
      [[ $value =~ ^$JSON_NUM$ ]] || {
        echo "JSON.get -n flag used but '$value' is not a number" >&2
        return 1
      }
      ;;
    b)
      [[ $value =~ ^$JSON_BOOL$ ]] || {
        echo "JSON.get -b flag used but '$value' is not a boolean" >&2
        return 1
      }
      value=$([ $value == true ] && echo "0" || echo "1")
      ;;
    z)
      [[ $value =~ ^$JSON_NULL$ ]] || {
        echo "JSON.get -z flag used but '$value' is not a null" >&2
        return 1
      }
      value=''
      ;;
    *) ;;
  esac
  echo "$value"
  return 0
}

JSON.assert-cache() {
  [[ -n $JSON__cache ]] || JSON.die 'JSON.get error: no cached data.'
}

JSON.die() {
  echo "$*" >&2
  exit 1
}

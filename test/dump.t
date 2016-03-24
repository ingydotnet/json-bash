#!/usr/bin/env bash

source test/setup

use Test::More tests 21
use JSON

dbg() {
    : diag "DBG: $1=${!1}"
}

test_dump() {
    JSON.style "$1"
    ok $? "JSON.style succeeded"

    json1="$(JSON.dump < test/dump.data)"
    dbg json1
    ok $? "JSON.dump succeeded"

    [ -n "$json1" ]
    ok $? "dumped result has content"

    JSON.load "$json1" tree1
    dbg tree1
    ok $? "dumped json can be loaded"

    json2="$(echo "$tree1" | JSON.dump)"
    dbg json2
    is "$json2" "$json1" "dump | load | dump produces same result as dump"

    is "$(grep -o : <<<"$json1" | wc -l)" \
        "$(grep -oE '/[^/	]*' test/dump.data | sort -u | grep -cvE '/[0-9]*$')" \
        "dumped result contains correct number of keys"

    like "$json1" '"x y z": *"spaces"' "keys with spaces work correctly"
}

test_dump normal
test_dump minimal
test_dump pretty

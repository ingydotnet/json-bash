#!/usr/bin/env bash

source test/setup

use Test::More tests 6
use JSON

tree1=$(cat test/keys.json | JSON.load)
ok $? \
    "JSON.load succeeded"

is "$(JSON.get '/files/file 2.txt/type' tree1)" \
    '"text/plain"' \
    "JSON.get works"

file_object=$(JSON.object '/files' tree1)

expect="file1.txt"$'\n'"file 2.txt"

keys="$(JSON.keys '/' file_object)"
is "$keys" \
    "$expect" \
    "JSON.keys '/'" #'

keys="$(JSON.keys '/files' tree1)"
is "$keys" \
    "$expect" \
    "JSON.keys '/files'" #'

keys="$(JSON.keys '/' tree1)"
is "$keys" "description"$'\n'"files" \
    "JSON.keys '/'" #'

keys="$(JSON.keys '/files/file 2.txt' tree1)"
is "$keys" \
    "type"$'\n'"content" \
    "JSON.keys '/files/file 2.txt'" #'

#!/usr/bin/env bash

source test/setup

# Number denotes how many tests are to be executed.
use Test::More tests 7
use JSON

# Testing json where an array element is not the first or the last one.
# Check test/arrays1.json.
# ------------------------------------------------------------------------------

# 1. Does it load?
tree=$(cat test/arrays1.json | JSON.load)
ok $? "JSON.load succeeded"

# 2. Does it fetch first element being non-array?
is "$(JSON.get '/id' tree)" '"20150817"' "JSON.get works on first element."

# 3. Escaped quotes?
is "$(JSON.get '/_etag' tree)" '""0300e163-0000-0000-0000-55d223bd0000""' "JSON.get works on escaped quoates"

# 4. Retrieving the first array element.
is "$(JSON.get '/osList' tree)" '' "JSON.get works on first array element."

# 5. Retrieving a simple value of an element of the first array element.
is "$(JSON.get '/osList/1/osName' tree)" '"Mac"' "JSON.get works on a simple value of an element of the first array element."

# 6. Retrieving an array element of an element of the first array element.
is "$(JSON.get '/osList/1/softwareList' tree)" '' "JSON.get works on an array element of an element of the first array element."

# 7. Retrieving a simple value of an element of an array of an element of element of the first array element.
is "$(JSON.get '/osList/1/softwareList/1/softwareName' tree)" '"VirtualBox"' "JSON.get works on a simple value of an element of an array of an element of element of the first array element."

# trailing_newline_re=$'\n''$'
# json_string='{"foo": "bar", "baz": "quux"}'
#
# JSON.load "$json_string"
# [[ "$JSON__cache" =~ $trailing_newline_re ]]
# ok $? "JSON__cache has trailing newline" || echo -n "$JSON__cache" | hexdump -C
#
# JSON.load "$json_string" tree
# [[ "$tree" =~ $trailing_newline_re ]]
# ok $? "linear tree has trailing newline" || echo -n "$tree" | hexdump -C
#
# JSON.load "{}"
# [[ "$JSON__cache" == '' ]]
# ok $? "empty JSON__cache has no trailing newline" || echo -n "$JSON__cache" | hexdump -C
#
# JSON.load "[]" tree
# [[ "$tree" == '' ]]
# ok $? "empty linear tree has no trailing newline" || echo -n "$tree" | hexdump -C

# Testing json where an array element is the first element.
# Check test/arrays2.json.
# ------------------------------------------------------------------------------

# Testing json where an array element is the last element.
# Check test/arrays3.json.
# ------------------------------------------------------------------------------

# Testing json where an array element is the first and the last element only.
# Check test/arrays4.json.
# ------------------------------------------------------------------------------

# Testing json where an array element is the first, the last element and more exist.
# Check test/arrays5.json.
# ------------------------------------------------------------------------------

#!/usr/bin/env bash

source test/setup

# Number denotes how many tests are to be executed.
use Test::More tests 45
use JSON

# Testing json where an array element is not the first or the last one.
# Check test/arrays1.json.
# ------------------------------------------------------------------------------

# 1.1. Does it load?
tree=$(cat test/arrays1.json | JSON.load)
ok $? "JSON.load succeeded"

# 1.2. Does it fetch first element being non-array?
is "$(JSON.get '/id' tree)" '"20150817"' "JSON.get works on first element."

# 1.3. Escaped quotes?
is "$(JSON.get -s '/_etag' tree)" '\"0300e163-0000-0000-0000-55d223bd0000\"' "JSON.get works on escaped quotes"

# 1.4. Escaped quotes?
is "$(JSON.get -s -e '/_etag' tree)" '"0300e163-0000-0000-0000-55d223bd0000"' "JSON.get works on escaped quotes"

# 1.5. Escaped quotes?
is "$(JSON.get -e '/_etag' tree)" '""0300e163-0000-0000-0000-55d223bd0000""' "JSON.get works on escaped quotes"

# 1.6. Retrieving the first array element.
is "$(JSON.get '/osList' tree)" '' "JSON.get works on first array element."

# 1.7. Retrieving a simple value of an element of the first array element.
is "$(JSON.get '/osList/1/osName' tree)" '"Mac"' "JSON.get works on a simple value of an element of the first array element."

# 1.8. Retrieving an array element of an element of the first array element.
is "$(JSON.get '/osList/1/softwareList' tree)" '' "JSON.get works on an array element of an element of the first array element."

# 1.9. Retrieving a simple value of an element of an array of an element of element of the first array element.
is "$(JSON.get '/osList/1/softwareList/1/softwareName' tree)" '"VirtualBox"' "JSON.get works on a simple value of an element of an array of an element of element of the first array element."

# Testing json where an array element is the first element.
# Check test/arrays2.json.
# ------------------------------------------------------------------------------

# 2.1. Does it load?
tree=$(cat test/arrays1.json | JSON.load)
ok $? "JSON.load succeeded"

# 2.2. Does it fetch first element being non-array?
is "$(JSON.get '/id' tree)" '"20150817"' "JSON.get works on first element."

# 2.3. Escaped quotes?
is "$(JSON.get -s '/_etag' tree)" '\"0300e163-0000-0000-0000-55d223bd0000\"' "JSON.get works on escaped quotes"

# 2.4. Escaped quotes?
is "$(JSON.get -s -e '/_etag' tree)" '"0300e163-0000-0000-0000-55d223bd0000"' "JSON.get works on escaped quotes"

# 2.5. Escaped quotes?
is "$(JSON.get -e '/_etag' tree)" '""0300e163-0000-0000-0000-55d223bd0000""' "JSON.get works on escaped quotes"

# 2.6. Retrieving the first array element.
is "$(JSON.get '/osList' tree)" '' "JSON.get works on first array element."

# 2.7. Retrieving a simple value of an element of the first array element.
is "$(JSON.get '/osList/1/osName' tree)" '"Mac"' "JSON.get works on a simple value of an element of the first array element."

# 2.8. Retrieving an array element of an element of the first array element.
is "$(JSON.get '/osList/1/softwareList' tree)" '' "JSON.get works on an array element of an element of the first array element."

# 2.9. Retrieving a simple value of an element of an array of an element of element of the first array element.
is "$(JSON.get '/osList/1/softwareList/1/softwareName' tree)" '"VirtualBox"' "JSON.get works on a simple value of an element of an array of an element of element of the first array element."

# Testing json where an array element is the last element.
# Check test/arrays3.json.
# ------------------------------------------------------------------------------

# 3.1. Does it load?
tree=$(cat test/arrays1.json | JSON.load)
ok $? "JSON.load succeeded"

# 3.2. Does it fetch first element being non-array?
is "$(JSON.get '/id' tree)" '"20150817"' "JSON.get works on first element."

# 3.3. Escaped quotes?
is "$(JSON.get -s '/_etag' tree)" '\"0300e163-0000-0000-0000-55d223bd0000\"' "JSON.get works on escaped quotes"

# 3.4. Escaped quotes?
is "$(JSON.get -s -e '/_etag' tree)" '"0300e163-0000-0000-0000-55d223bd0000"' "JSON.get works on escaped quotes"

# 3.5. Escaped quotes?
is "$(JSON.get -e '/_etag' tree)" '""0300e163-0000-0000-0000-55d223bd0000""' "JSON.get works on escaped quotes"

# 3.6. Retrieving the first array element.
is "$(JSON.get '/osList' tree)" '' "JSON.get works on first array element."

# 3.7. Retrieving a simple value of an element of the first array element.
is "$(JSON.get '/osList/1/osName' tree)" '"Mac"' "JSON.get works on a simple value of an element of the first array element."

# 3.8. Retrieving an array element of an element of the first array element.
is "$(JSON.get '/osList/1/softwareList' tree)" '' "JSON.get works on an array element of an element of the first array element."

# 3.9. Retrieving a simple value of an element of an array of an element of element of the first array element.
is "$(JSON.get '/osList/1/softwareList/1/softwareName' tree)" '"VirtualBox"' "JSON.get works on a simple value of an element of an array of an element of element of the first array element."

# Testing json where an array element is the first and the last element only.
# Check test/arrays4.json.
# ------------------------------------------------------------------------------

# 4.1. Does it load?
tree=$(cat test/arrays1.json | JSON.load)
ok $? "JSON.load succeeded"

# 4.2. Does it fetch first element being non-array?
is "$(JSON.get '/id' tree)" '"20150817"' "JSON.get works on first element."

# 4.3. Escaped quotes?
is "$(JSON.get -s '/_etag' tree)" '\"0300e163-0000-0000-0000-55d223bd0000\"' "JSON.get works on escaped quotes"

# 4.4. Escaped quotes?
is "$(JSON.get -s -e '/_etag' tree)" '"0300e163-0000-0000-0000-55d223bd0000"' "JSON.get works on escaped quotes"

# 4.5. Escaped quotes?
is "$(JSON.get -e '/_etag' tree)" '""0300e163-0000-0000-0000-55d223bd0000""' "JSON.get works on escaped quotes"

# 4.6. Retrieving the first array element.
is "$(JSON.get '/osList' tree)" '' "JSON.get works on first array element."

# 4.7. Retrieving a simple value of an element of the first array element.
is "$(JSON.get '/osList/1/osName' tree)" '"Mac"' "JSON.get works on a simple value of an element of the first array element."

# 4.8. Retrieving an array element of an element of the first array element.
is "$(JSON.get '/osList/1/softwareList' tree)" '' "JSON.get works on an array element of an element of the first array element."

# 4.9. Retrieving a simple value of an element of an array of an element of element of the first array element.
is "$(JSON.get '/osList/1/softwareList/1/softwareName' tree)" '"VirtualBox"' "JSON.get works on a simple value of an element of an array of an element of element of the first array element."

# Testing json where an array element is the first, the last element and more exist.
# Check test/arrays5.json.
# ------------------------------------------------------------------------------

# 5.1. Does it load?
tree=$(cat test/arrays1.json | JSON.load)
ok $? "JSON.load succeeded"

# 5.2. Does it fetch first element being non-array?
is "$(JSON.get '/id' tree)" '"20150817"' "JSON.get works on first element."

# 5.3. Escaped quotes?
is "$(JSON.get -s '/_etag' tree)" '\"0300e163-0000-0000-0000-55d223bd0000\"' "JSON.get works on escaped quotes"

# 5.4. Escaped quotes?
is "$(JSON.get -s -e '/_etag' tree)" '"0300e163-0000-0000-0000-55d223bd0000"' "JSON.get works on escaped quotes"

# 5.5. Escaped quotes?
is "$(JSON.get -e '/_etag' tree)" '""0300e163-0000-0000-0000-55d223bd0000""' "JSON.get works on escaped quotes"

# 5.6. Retrieving the first array element.
is "$(JSON.get '/osList' tree)" '' "JSON.get works on first array element."

# 5.7. Retrieving a simple value of an element of the first array element.
is "$(JSON.get '/osList/1/osName' tree)" '"Mac"' "JSON.get works on a simple value of an element of the first array element."

# 5.8. Retrieving an array element of an element of the first array element.
is "$(JSON.get '/osList/1/softwareList' tree)" '' "JSON.get works on an array element of an element of the first array element."

# 5.9. Retrieving a simple value of an element of an array of an element of element of the first array element.
is "$(JSON.get '/osList/1/softwareList/1/softwareName' tree)" '"VirtualBox"' "JSON.get works on a simple value of an element of an array of an element of element of the first array element."

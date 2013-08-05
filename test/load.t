#!/bin/bash

PATH=lib:ext/test-simple-bash/lib:$PATH
source test-simple.bash tests 13
source json.bash

tree1=$(cat test/test1.json | JSON.load)
ok [ $? -eq 0 ]                 "JSON.load succeeded"
[ -z "$JSON__cache" ]
ok [ $? -eq 0 ]                 "JSON__cache is unset"
[ -n "$tree1" ]
ok [ $? -eq 0 ]                 "load result has content"

echo "$tree1" | grep -E "^/owner/login" &> /dev/null
ok [ $? -eq 0 ]  "load output contains login key"

ok [ $(echo "$tree1" | wc -l) -eq 12 ] \
                                "linear tree has 12 values"

JSON.load "$(cat test/test1.json)"
ok [ $? -eq 0 ]                 "JSON.load succeeded"
[ -n "$JSON__cache" ]
ok [ $? -eq 0 ]                 "JSON__cache is set"

JSON.cache | grep -E '^/description' &> /dev/null
ok [ $? -eq 0 ]  "load output contains description"

ok [ $(JSON.cache | wc -l) -eq 12 ] \
                                "linear tree has 12 values"

JSON.load "$(cat test/test1.json)" tree2
ok [ $? -eq 0 ]                 "JSON.load succeeded"
[ -z "$JSON__cache" ]
ok [ $? -eq 0 ]                 "JSON__cache is set"

echo "$tree2" | grep -E '^/id' &> /dev/null
ok [ $? -eq 0 ]  "load output contains id"

ok [ $(echo "$tree2" | wc -l) -eq 12 ] \
                                "linear tree has 12 values"


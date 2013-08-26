#!/bin/bash

PATH=lib:ext/test-simple-bash/lib:$PATH
source test-simple.bash tests 6
source json.bash

tree1=$(cat test/test1.json | JSON.load)
ok $?                           "JSON.load succeeded"
ok [ "$(JSON.get '/owner/login' tree1)" == '"ingydotnet"' ] \
                                "JSON.get works"
ok [ "$(JSON.get -s '/owner/login' tree1)" == 'ingydotnet' ] \
                                "JSON.get -s works"
ok [ $(JSON.get -s '/id' tree1 2> /dev/null || echo $?) -eq 1 ] \
                                "JSON.get -s failure works"

JSON.load "$(< test/test1.json)"
ok $?                           "JSON.load succeeded"
ok [ "$(JSON.get '/owner/login' -)" == '"ingydotnet"' ] \
                                "JSON.get works"
# XXX Disabling for now because we can't depend on pipefail
# Maybe use a tee and `wc -l` and check 0 or 1
# JSON.get '/bad-key' -
# ok [ $? -eq 1 ]                 "JSON.get on bad key fails"

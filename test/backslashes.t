#!/usr/bin/env bash

source test/setup

use Test::More tests 13
use JSON

# 1. Does it load?
tree=$(cat test/backslashes.json | JSON.load)
ok $? "JSON.load succeeded"

# 2. Escaping quotes.
is "$(JSON.get '/backslashed_quotes' tree)" '"\"wow\"wow\""' "JSON.get works on backslashes."

# 3. Not escaping quotes.
is "$(JSON.get -e '/backslashed_quotes' tree)" '""wow"wow""' "JSON.get works on backslashes."

# 4. Escaping backslashes.
is "$(JSON.get '/backslashed_backslashes' tree)" '"\\wow\\wow\\"' "JSON.get works on backslashes."

# 5. Not escaping backslashes.
is "$(JSON.get -e '/backslashed_backslashes' tree)" '"\wow\wow\"' "JSON.get works on backslashes."

# 6. Escaping various combinations.
is "$(JSON.get '/backslashed_all' tree)" '"\\\"wow\"\\\"wow\"\\\""' "JSON.get works on backslashes."

# 7. Not escaping various combinations.
is "$(JSON.get -e '/backslashed_all' tree)" '"\"wow"\"wow"\""' "JSON.get works on backslashes."

# 8. Lets test flag -s.
is "$(JSON.get -s '/backslashed_all' tree)" '\\\"wow\"\\\"wow\"\\\"' "JSON.get works on backslashes."

# 9. Lets combine it with flag -s.
is "$(JSON.get -s -e '/backslashed_all' tree)" '\"wow"\"wow"\"' "JSON.get works on backslashes."

# 10. Lets put secondary flags first.
is "$(JSON.get -e -s '/backslashed_all' tree)" '\"wow"\"wow"\"' "JSON.get works on backslashes."

# 11. Lets test flag -a.
is "$(JSON.get -a '/backslashed_all' tree)" '\\\"wow\"\\\"wow\"\\\"' "JSON.get works on backslashes."

# 12. Lets combine it with flag -a.
is "$(JSON.get -a -e '/backslashed_all' tree)" '\"wow"\"wow"\"' "JSON.get works on backslashes."

# 13. Lets put secondary flags first.
is "$(JSON.get -e -a '/backslashed_all' tree)" '\"wow"\"wow"\"' "JSON.get works on backslashes."

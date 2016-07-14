#!/bin/bash

# Go to tests directory.
cd $(dirname "$0")/..

# The path to cton-util should be in $CTONUTIL.
if [ -z "$CTONUTIL" ]; then
    CTONUTIL=../src/tools/target/debug/cton-util
fi

if [ ! -x "$CTONUTIL" ]; then
    echo "Can't fund executable cton-util: $CTONUTIL" 1>&2
    exit 1
fi

declare -a fails

for testcase in $(find cfg -name '*.cton'); do
    annotations=$(cat $testcase | awk /';;;;'/ | awk -F ";;;;" '{print $2}' | sort)
    connections=$("${CTONUTIL}" print-cfg "$testcase" | awk /"->"/ | sort)
    if diff -u <(echo $annotations) <(echo $connections); then
        echo OK $testcase
    else
        fails=(${fails[@]} "$testcase")
        echo FAIL $testcase
    fi
done

if [ ${#fails[@]} -ne 0 ]; then
    echo
    echo Failures:
    for f in "${fails[@]}"; do
        echo "  $f"
    done
    exit 1
else
    echo "All passed"
fi

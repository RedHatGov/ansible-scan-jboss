#!/bin/bash

pushd $(dirname $0) &> /dev/null
BINDIR=$(pwd)

TARGET="$BINDIR/test-distros/community"

echo
echo Community Search Results
echo "EXPECTED = $(find $TARGET -maxdepth 1 -type d | grep -v 'community$' | wc -l)"
echo -n "   FOUND = "

for i in $(find $TARGET -maxdepth 1 -type d | grep -v 'community$')
do
    pushd $i &> /dev/null
    $BINDIR/scan-community.sh
    popd &> /dev/null
done | grep 'community found' | wc -l
echo

TARGET="$BINDIR/test-distros/enterprise"

echo Enterprise Null Search Results
echo -n "EXPECTED =        0 (out of "
echo "$(find $TARGET -maxdepth 1 -type d | grep -v 'enterprise$' | wc -l | sed 's/ //g'))"
echo -n "   FOUND = "

for i in $(find $TARGET -maxdepth 1 -type d | grep -v 'enterprise$')
do
    pushd $i &> /dev/null
    $BINDIR/scan-community.sh
    popd &> /dev/null
done | grep 'enterprise found' | wc -l
echo


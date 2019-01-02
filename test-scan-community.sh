#!/bin/bash

pushd $(dirname $0) &> /dev/null
BINDIR=$(pwd)
popd &> /dev/null

TARGET="$BINDIR/test-distros/community"

echo
echo Community Search Results
echo "EXPECTED = $(find $TARGET -maxdepth 1 -type d | grep -v 'community$' | wc -l | sed 's/ //g')"
echo -n "   FOUND = "

for i in $(find $TARGET -maxdepth 1 -type d | grep -v 'community$')
do
    export XCCDF_VALUE_SEARCHROOT=$i
    $BINDIR/scan-community.sh
done | grep 'Unsupported JBoss community open source software has been found' | wc -l | sed 's/ //g'
echo

TARGET="$BINDIR/test-distros/enterprise"

echo Enterprise Null Search Results
echo -n "EXPECTED = 0 (out of "
echo "$(find $TARGET -maxdepth 1 -type d | grep -v 'enterprise$' | wc -l | sed 's/ //g'))"
echo -n "   FOUND = "

for i in $(find $TARGET -maxdepth 1 -type d | grep -v 'enterprise$')
do
    export XCCDF_VALUE_SEARCHROOT=$i
    $BINDIR/scan-community.sh
done | grep 'Unsupported JBoss community open source software has been found' | wc -l | sed 's/ //g'
echo


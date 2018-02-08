#!/usr/bin/env bash

CUT=/usr/bin/cut
FIND=/usr/bin/find
GREP=/usr/bin/grep
SED=/usr/bin/sed
SORT=/usr/bin/sort
TR=/usr/bin/tr
UNZIP=/usr/bin/unzip
WC=/usr/bin/wc

if ! [ -x $CUT -a -x $FIND -a -x $GREP -a -x $SED -a -x $SORT -a -x $TR -a -x $UNZIP -a -x $WC ]
then
	echo "JBoss community software checks require that the following commands are installed:"
        echo "	cut, find, grep, sed, tr, unzip, wc"
	echo "The unzip command is only used to examine file content without extraction."
        echo "Please install the above commands and re-run the checks."

	exit $XCCDF_RESULT_FAIL
fi

SEARCHROOT=.
if [[ $XCCDF_VALUE_searchroot ]]
then
	SEARCHROOT=$XCCDF_VALUE_searchroot
fi
	
pushd $SEARCHROOT &> /dev/null

TGT=jboss-modules.jar
METAPATH=META-INF/maven/org.jboss.modules/jboss-modules/pom.properties
MATCH_COMMUNITY='([0-9]+\.){3}(GA|CR[0-9]+|Final|Beta[0-9]+)$'

FOUND_jbossmodules=$($FIND . -type f -name "$TGT" -exec $UNZIP -p {} "$METAPATH" \; | \
    $GREP version | $CUT -d= -f2 | \
    $GREP -E "$MATCH_COMMUNITY" | $WC -l)

TGT=run.jar
METAPATH=META-INF/MANIFEST.MF
MATCH_COMMUNITY='(Branch(_[0-9]+){2})|(JBoss(_[0-9]+){3}(($)|(_RC[0-9])|(_SP[0-9])|(_Beta[0-9])|(_CR[0-9])|(_M[0-9])|_GA))|(JBoss_([0-9]+\.){3}((Final)|([0-9]{8}((\-M)|(\-CR))[0-9])))$'

FOUND_run=$($FIND . -type f -name "$TGT" -exec $UNZIP -p {} "$METAPATH" \; | \
    $GREP -A1 'Implementation-Version\|Implementation-Title' | \
    $TR '\r\n' ' ' | \
    $SED 's/..*[CS]V[NS]Tag..*JBoss_/JBoss_/g' | \
    $SED 's/..*[CS]V[NS]Tag..*Branch_/Branch_/g' | \
    $SED 's/\([0-9]\)  *\([0-9]\)/\1\2/g' | \
    $CUT -d' ' -f1 | \
    $GREP -E "$MATCH_COMMUNITY" | $WC -l)

popd &> /dev/null

if [ $FOUND_jbossmodules -ne 0 -o $FOUND_run -ne 0 ]
then
	echo "Unsupported JBoss community software has been found at one or more of the following locations:"
        $FIND . -type f \( -name jboss-modules.jar -o -name run.jar \)

	exit $XCCDF_RESULT_FAIL
fi

exit $XCCDF_RESULT_PASS


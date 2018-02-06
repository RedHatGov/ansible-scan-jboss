#!/bin/bash

TGT=jboss-modules.jar
METAPATH=META-INF/maven/org.jboss.modules/jboss-modules/pom.properties
MATCH_COMMUNITY='([0-9]+\.){3}(GA|CR[0-9]+|Final|Beta[0-9]+)$'

FOUND_jbossmodules=$(/usr/bin/find . -type f -name "$TGT" -exec /usr/bin/unzip -p {} "$METAPATH" \; | \
    /usr/bin/grep version | /usr/bin/cut -d= -f2 | \
    /usr/bin/grep -E "$MATCH_COMMUNITY" | /usr/bin/wc -l)

TGT=run.jar
METAPATH=META-INF/MANIFEST.MF
MATCH_COMMUNITY='(Branch(_[0-9]+){2})|(JBoss(_[0-9]+){3}(($)|(_RC[0-9])|(_SP[0-9])|(_Beta[0-9])|(_CR[0-9])|(_M[0-9])|_GA))|(JBoss_([0-9]+\.){3}((Final)|([0-9]{8}((\-M)|(\-CR))[0-9])))$'

FOUND_run=$(/usr/bin/find . -type f -name "$TGT" -exec /usr/bin/unzip -p {} "$METAPATH" \; | \
    /usr/bin/grep -A1 'Implementation-Version\|Implementation-Title' | \
    /usr/bin/tr '\r\n' ' ' | \
    /usr/bin/sed 's/..*[CS]V[NS]Tag..*JBoss_/JBoss_/g' | \
    /usr/bin/sed 's/..*[CS]V[NS]Tag..*Branch_/Branch_/g' | \
    /usr/bin/sed 's/\([0-9]\)  *\([0-9]\)/\1\2/g' | \
    /usr/bin/cut -d' ' -f1 | \
    /usr/bin/grep -E "$MATCH_COMMUNITY" | /usr/bin/wc -l)

if [ "$FOUND_jbossmodules" -ne 0 -o "$FOUND_run" -ne 0 ]
then
    echo "community found"
fi


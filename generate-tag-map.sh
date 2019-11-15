#!/usr/bin/env bash

# This script is used against a large test dataset to generate the
# classification file contents for inclusion in the scan-jboss script.
# This is intended for development use only and is only as good as
# the test dataset.

# abort if error
set -e

# default arguments for the scanning module
WorkDir=/tmp
SearchRoot=/Users/rlucente/development/git/ansible-scan-jboss/test-distros

# switch to scratch directory
pushd ${WorkDir} &> /dev/null

  MODDIR="META-INF/maven/org.jboss.modules/jboss-modules"

  # find every occurrence of the modules jar in the filesystem (excluding
  # redundant copies from patching)
  for jar in `find ${SearchRoot} -type f -name 'jboss-modules.jar' | \
                 grep -v '\.installation/patches'`
  do
    FILENAME=$(echo -n "$jar" | sed 's/..*community/community/g' | sed 's/..*enterprise/enterprise/g' | cut -d/ -f1,2)
    echo -n "$FILENAME "
    unzip -p ${jar} ${MODDIR}/pom.properties | grep version | sed 's/version=//g'
  done | awk '{print $2 " " $1}' | sort > tmp.list

  # find every occurrence of the run jar in the filesystem
  for runjar in `find ${SearchRoot} -type f -name 'run.jar'`
  do
    FILENAME=$(echo -n "$runjar" | sed 's/..*community/community/g' | sed 's/..*enterprise/enterprise/g' | cut -d/ -f1,2)
    echo -n "$FILENAME "
    unzip -p ${runjar} META-INF/MANIFEST.MF | grep -A1 Implementation-Version | tr '\r\n' ' ' | sed 's/..*[CS]V[SN]Tag[:=]//g' | \
      sed 's/d   ate[=:]..*//g' | sed 's/da   te[=:]..*//g' | sed 's/date[=:]..*//g' | sed 's/Date[=:]..*//g' | sed 's/  *//g' | \
      rev | cut -d/ -f1 | rev
  done | awk '{print $2 " " $1}' | sort >> tmp.list

  awk '{print $1}' tmp.list | sort -u > tmp.uniq.tag
  for tag in $(cat tmp.uniq.tag)
  do
    grep "$tag " tmp.list | awk '{print $2 ": " $1; exit}'
  done | sort

  rm -fr tmp.list tmp.uniq.tag
popd &> /dev/null


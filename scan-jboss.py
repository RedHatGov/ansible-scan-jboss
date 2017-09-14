#!/usr/bin/env python

import multiprocessing
import os
import re
import shutil
import socket
import zipfile

"""Scans for deployed JBoss instances by searching for the
jboss-modules.jar and run.jar files and then extracting the
pom.properties file and MANIFEST.MF, respectively. The installed
JBoss instance is determined using the version property."""

__author__ = 'Rich Lucente, Jason Callaway'
__email__ = 'rlucente@redhat.com'
__license__ = 'Apache License Version 2.0'
__version__ = '0.1'
__status__ = 'alpha'

work_dir = '/tmp'
search_root = ['/etc', '/home', '/var', '/usr', '/opt']
#search_root = ['/Users/rlucente/demo/eap-test']

# This script finds and classifies JBoss AS instances by specific community and
# enterprise releases.
#
# Classification is simple: search for jboss-modules.jar and run.jar files and
# then extract the version from the pom.properties and MANIFEST.MF,
# respectively, to determine which distribution contained the jar.
#
# NB:  This script is up to date through EAP 6.4 CP16, EAP 7.0 CP07,
#      EAP 7.1 Beta, and WildFly 11.0.0.CR1

classifications = {
    'JBoss_4_0_0': 'JBossAS-4',
    'JBoss_4_0_1_SP1': 'JBossAS-4',
    'JBoss_4_0_2': 'JBossAS-4',
    'JBoss_4_0_3_SP1': 'JBossAS-4',
    'JBoss_4_0_4_GA': 'JBossAS-4',
    'Branch_4_0': 'JBossAS-4',
    'JBoss_4_2_0_GA': 'JBossAS-4',
    'JBoss_4_2_1_GA': 'JBossAS-4',
    'JBoss_4_2_2_GA': 'JBossAS-4',
    'JBoss_4_2_3_GA': 'JBossAS-4',
    'JBoss_5_0_0_GA': 'JBossAS-5',
    'JBoss_5_0_1_GA': 'JBossAS-5',
    'JBoss_5_1_0_GA': 'JBossAS-5',
    'JBoss_6.0.0.Final': 'JBossAS-6',
    'JBoss_6.1.0.Final': 'JBossAS-6',
    '1.0.1.GA': 'JBossAS-7',
    '1.0.2.GA': 'JBossAS-7',
    '1.1.1.GA': 'JBossAS-7',
    '1.2.0.CR1': 'JBossAS-7',
    '1.2.0.Final': 'WildFly-8',
    '1.2.2.Final': 'WildFly-8',
    '1.2.4.Final': 'WildFly-8',
    '1.3.0.Beta3': 'WildFly-8',
    '1.3.0.Final': 'WildFly-8',
    '1.3.3.Final': 'WildFly-8',
    '1.3.4.Final': 'WildFly-9',
    '1.4.2.Final': 'WildFly-9',
    #'1.4.3.Final': 'WildFly-9',
    '1.4.3.Final': 'WildFly-10',
    '1.4.4.Final': 'WildFly-10',
    '1.5.0.Final': 'WildFly-10',
    '1.5.1.Final': 'WildFly-10',
    '1.5.2.Final': 'WildFly-10',
    '1.6.0.Beta6': 'WildFly-11',
    '1.6.0.CR2': 'WildFly-11',
    '1.6.0.Final': 'WildFly-11',
    'JBPAPP_4_2_0_GA': 'EAP-4.2',
    'JBPAPP_4_2_0_GA_C': 'EAP-4.2',
    'JBPAPP_4_3_0_GA': 'EAP-4.3',
    'JBPAPP_4_3_0_GA_C': 'EAP-4.3',
    'JBPAPP_5_0_0_GA': 'EAP-5.0.0',
    'JBPAPP_5_0_1': 'EAP-5.0.1',
    'JBPAPP_5_1_0': 'EAP-5.1.0',
    'JBPAPP_5_1_1': 'EAP-5.1.1',
    'JBPAPP_5_1_2': 'EAP-5.1.2',
    'JBPAPP_5_2_0': 'EAP-5.2.0',
    '1.1.2.GA-redhat-1': 'EAP-6.0.0',
    '1.1.3.GA-redhat-1': 'EAP-6.0.1',
    '1.2.0.Final-redhat-1': 'EAP-6.1.0',
    '1.2.2.Final-redhat-1': 'EAP-6.1.1',
    '1.3.0.Final-redhat-2': 'EAP-6.2',
    #'1.3.3.Final-redhat-1': 'EAP-6.2',
    '1.3.3.Final-redhat-1': 'EAP-6.3',
    '1.3.4.Final-redhat-1': 'EAP-6.3',
    '1.3.5.Final-redhat-1': 'EAP-6.3',
    '1.3.6.Final-redhat-1': 'EAP-6.4',
    '1.3.7.Final-redhat-1': 'EAP-6.4',
    '1.3.8.Final-redhat-1': 'EAP-6.4',
    '1.3.9.Final-redhat-1': 'EAP-6.4',
    '1.4.4.Final-redhat-1': 'EAP-7.0',
    '1.5.1.Final-redhat-1': 'EAP-7.0',
    '1.5.3.Final-redhat-1': 'EAP-7.0',
    '1.5.4.Final-redhat-1': 'EAP-7.0',
    '1.6.0.Beta6-redhat-1': 'EAP-7.1',
    '1.6.0.Beta9-redhat-1': 'EAP-7.1'
}

mod_file = 'META-INF/maven/org.jboss.modules/jboss-modules/pom.properties'
run_file = 'META-INF/MANIFEST.MF'

found_versions = []

for search_dir in search_root:
    for dirpath, dirs, files in os.walk(search_dir):
        for name in files:
            filename = os.path.join(dirpath, name)

            # Find every occurrence of the modules jar in the search roots
            # (excluding redundant copies from patching).
            if 'jboss-modules.jar' in filename and not '.installation/patches' in filename:
                zf = zipfile.ZipFile(filename)
                zf.extract(mod_file, work_dir)
                pom_file = open(work_dir + '/' + mod_file, 'r')
                zf.close()

                for line in pom_file:
                    if 'version' in line:
                        version = line.split('=')[1]
                        version = version.splitlines()[0]
                        if version in classifications:
                            found_versions.append(classifications[version])
                        else:
                            found_versions.append('Unknown-JBoss-Release: ' + version)
                pom_file.close()
                shutil.rmtree(work_dir + '/META-INF')
    
            # Find every occurrence of the run jar in the search roots.
            if 'run.jar' in filename:
                zf = zipfile.ZipFile(filename)
                zf.extract(run_file, work_dir)
                manifest_file = open(work_dir + '/' + run_file, 'r')
                zf.close()

                for line in manifest_file:
                    if 'Implementation-Version' in line:
                        line = re.sub('..*[CS]V[SN]Tag.', '', line)
                        line = re.sub('[\r\n]', '', line)
                        version = line.split(' ')[0]
                        if version in classifications:
                            found_versions.append(classifications[version])
                        else:
                            found_versions.append('Unknown-JBoss-Release: ' + version)

print('hostname=' + socket.gethostname()),
print('cores=' + str(multiprocessing.cpu_count())),
print('release='),
print(sorted(set(found_versions)))

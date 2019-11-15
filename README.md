ansible-scan-jboss
==================

[Ansible](http://ansible.com) is a configuration management tool that
enables running modules on remote systems without the need for remote
agent infrastructure.

For more information, see the [Ansible web site](http://ansible.com).

This Ansible module scans for deployed JBoss instances by searching
for the jboss-modules.jar and run.jar files and then extracts the
version from the pom.properties and MANIFEST.MF, respectively, to
determine which distribution contained the jar.

NB:  This script is up to date through EAP 6.4 CP22, EAP 7.0 CP09,
     EAP 7.1 CP06, EAP 7.2 CP04, EAP 7.3 Beta, and WildFly 18.0.1.Final


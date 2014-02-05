ansible-scan-jboss
==================

Ansible (http://ansible.com) is a configuration management tool that
enables running modules on remote systems without the need for remote
agent infrastructure.

For more information, see the Ansible web site.

This Ansible module scans for deployed JBoss instances by searching for
the jboss-modules.jar and then extracting the pom.properties file from it.
The installed JBoss instance is determined using the version property.

This is definitely a work in progress since it's written as a bash script.
A proper implementation would use python.  I followed chapter 5 of the
"Ansible Configuration Management" book to create this example.  The book
is available at

  http://www.packtpub.com/ansible-configuration-management/book


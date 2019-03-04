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

NB:  This script is up to date through EAP 6.4 CP21, EAP 7.0 CP09,
     EAP 7.1 CP06, EAP 7.2.0, and WildFly 16.0.0.Final

This has now been updated with a python script in addition to a
bash script.  The python script correctly works on both Linux and
Mac OSX, but it has not yet been tested with Microsoft Windows.
Also, the python script needs to be updated to match ansible
expectations for a custom module, per chapter 10 in the ["Ansible:
Up and Running" book](http://shop.oreilly.com/product/0636920035626.do).


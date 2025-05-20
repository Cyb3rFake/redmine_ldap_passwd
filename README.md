Redmine LDAP passwd plugin - forked from https://github.com/xeagle2/redmine_ldap_passwd
Supported LDAP backend - FreeIPA 4.x

Original Readme:
=================

# Redmine LDAP Passwd plugin >= Redmine 6.0

The plugin extends AuthSourceLdap to introduce the ability to recover or change user password.

### Features

* Allows to changed password and update LDAP record.
* Allows to recover password and update LDAP record.

**Notes**

* The solution has been tested on MS Active Directory only. It works only with SSL connection, please ensure SSL is configured on Active Directory side.

### Install

1. Follow Redmine [plugin installation instructions](http://www.redmine.org/projects/redmine/wiki/Plugins#Installing-a-plugin).
2. Add new LDAP connection and check the records in 'auth_sources' making sure column 'type'='AuthSourceLdapPasswd'. If it is not, update the record manually executing the SQL query.
3. Assign new LDAP connection to the specific users you would like to provide access through LDAP to.

### Uninstall

1. Follow Redmine [plugin uninstall instructions](http://www.redmine.org/projects/redmine/wiki/Plugins#Uninstalling-a-plugin).

### Changelog

* **3.0 (2016-05-31)**
    * Initial version released.
* **3.0.5 (2025-05.20)**
    * Initial version released.
    
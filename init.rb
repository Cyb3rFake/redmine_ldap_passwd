require 'redmine'

Redmine::Plugin.register :redmine_ldap_passwd do
  name 'Redmine LDAP Change Password'
  author 'Yura Zaplavnov'
  description 'Extends AuthSourceLdap to allow LDAP password changes and recovery.'
  version '3.0.1'
  url 'https://github.com/xeagle2/redmine_ldap_passwd'
  author_url 'https://github.com/xeagle2'
end

Rails.configuration.to_prepare do
  require_dependency 'redmine_ldap_passwd/my_controller_patch'
  require_dependency 'redmine_ldap_passwd/auth_sources_helper_patch'
  require_dependency 'redmine_ldap_passwd/account_controller_patch'

  MyController.include RedmineLdapPasswd::MyControllerPatch
  AuthSourcesHelper.include RedmineLdapPasswd::AuthSourcesHelperPatch
  AccountController.include RedmineLdapPasswd::AccountControllerPatch
end

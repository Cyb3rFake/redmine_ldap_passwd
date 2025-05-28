require 'redmine'

Redmine::Plugin.register :redmine_ldap_passwd do
  name 'Redmine LDAP Change Password'
  author 'Yura Zaplavnov'
  description 'Extends AuthSourceLdap to allow LDAP password changes and recovery.'
  version '6.0.0'
  url 'https://github.com/Cyb3rFake/redmine_ldap_passwd'
  author_url 'https://github.com/Cyb3rFake'

  # Задаём разрешения (если добавляется новая страница)
  project_module :ldap_password do
    permission :change_ldap_password, { my: [:change_ldap_password] }, public: false
  end
end


Rails.application.config.to_prepare do
  require_dependency 'redmine_ldap_passwd/my_controller_patch'
  require_dependency 'redmine_ldap_passwd/auth_sources_helper_patch'
  require_dependency 'redmine_ldap_passwd/account_controller_patch'

  MyController.include RedmineLdapPasswd::MyControllerPatch unless MyController.included_modules.include?(RedmineLdapPasswd::MyControllerPatch)
  AuthSourcesHelper.include RedmineLdapPasswd::AuthSourcesHelperPatch unless AuthSourcesHelper.included_modules.include?(RedmineLdapPasswd::AuthSourcesHelperPatch)
  AccountController.include RedmineLdapPasswd::AccountControllerPatch unless AccountController.included_modules.include?(RedmineLdapPasswd::AccountControllerPatch)
end

module RedmineLdapPasswd
  module AuthSourcesHelperPatch
    # Пример метода, добавляемого в хелпер
    def ldap_passwd_enabled?(auth_source)
      auth_source.is_a?(AuthSourceLdap) && auth_source.account_password.present?
    end
  end
end

# Применение patch через prepend (Zeitwerk-friendly)
module AuthSourcesHelper
  prepend RedmineLdapPasswd::AuthSourcesHelperPatch
end

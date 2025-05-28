module RedmineLdapPasswd
  module AuthSourcesHelperPatch
    def self.included(base)
      base.class_eval do
        alias_method :auth_source_partial_name_without_ldap, :auth_source_partial_name
        alias_method :auth_source_partial_name, :auth_source_partial_name_with_ldap
      end
    end

    def auth_source_partial_name_with_ldap(source)
      if source.is_a?(AuthSourceLdapPasswd)
        'ldap_passwd'
      else
        auth_source_partial_name_without_ldap(source)
      end
    end
  end
end
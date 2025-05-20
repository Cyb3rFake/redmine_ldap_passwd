class AuthSourceLdapPasswd < AuthSourceLdap
  def allow_password_changes?
    tls
  end

  def change_user_password(user, current_password, new_password)
    return false unless AuthSourceLdapPasswd.change_password_allowed?(user)

    attrs = get_user_dn(user.login, current_password)
    return false unless attrs&.[](:dn)

    ldap_user = if account&.include?("$login")
                  initialize_ldap_con(account.sub("$login", Net::LDAP::DN.escape(user.login)), current_password)
                else
                  initialize_ldap_con(account, account_password)
                end

    ops = [[:replace, :userPassword, new_password]]
    ldap_user.modify(dn: attrs[:dn], operations: ops)

    result = ldap_user.get_operation_result
    if result.code == 0
      user.passwd_changed_on = Time.now.change(usec: 0)
      user.save
      true
    else
      result
    end
  rescue Net::LDAP::Error => e
    raise AuthSourceException, e.message
  end

  def self.str2unicodePwd(str)
    "\"#{str}\"".encode("utf-16le").force_encoding("utf-8")
  end

  def self.change_password_allowed?(user)
    user&.auth_source&.type == name
  end

  def self.is_password_valid(password)
    return false if password.nil? || password.length < 7

    score = [
      password.match?(/\p{Lower}/) ? 1 : 0,
      password.match?(/\p{Upper}/) ? 1 : 0,
      password.match?(/\p{Digit}/) ? 1 : 0,
      password.match?(/[^\w\d]/) ? 1 : 0
    ].sum

    score >= 3
  end
end

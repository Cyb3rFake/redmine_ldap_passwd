module RedmineLdapPasswd
  module AccountControllerPatch
    def self.included(base)
      base.class_eval do
        alias_method :lost_password_without_ldap, :lost_password
        alias_method :lost_password, :lost_password_with_ldap
      end
    end

    def lost_password_with_ldap
      if params[:token]
        @token = Token.find_token("recovery", params[:token].to_s)
        if @token.nil? || @token.expired?
          redirect_to home_url
          return
        end

        @user = @token.user
        unless @user&.active?
          redirect_to home_url
          return
        end

        if request.post?
          if params[:new_password] != params[:new_password_confirmation]
            flash.now[:error] = l(:notice_new_password_and_confirmation_different)
          elsif !AuthSourceLdapPasswd.is_password_valid(params[:new_password])
            flash.now[:error] = l(:notice_new_password_format)
          else
            result = @user.auth_source.change_user_password(@user, '', params[:new_password])
            if result == true
              flash[:notice] = l(:notice_account_password_updated)
              redirect_to signin_path
            elsif result == false
              lost_password_without_ldap
            else
              flash.now[:error] = result.message
            end
            return
          end
        end

        render template: 'account/password_recovery'
      else
        lost_password_without_ldap
      end
    rescue Net::LDAP::LdapError => e
      raise AuthSourceException, e.message
    end
  end
end

module RedmineLdapPasswd
  module AccountControllerPatch
    def lost_password
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
          if params[:new_password_confirmation] != params[:new_password]
            flash.now[:error] = l(:notice_new_password_and_confirmation_different)
          elsif !AuthSourceLdapPasswd.is_password_valid(params[:new_password])
            flash.now[:error] = l(:notice_new_password_format)
          else
            r = @user.auth_source.change_user_password(@user, '', params[:new_password])

            if r == true
              flash[:notice] = l(:notice_account_password_updated)
              redirect_to signin_path
            elsif r == false
              super
            else
              flash.now[:error] = r.message
            end
            return
          end
        end

        render template: "account/password_recovery"
      else
        super
      end
    rescue Net::LDAP::LdapError => e
      raise AuthSourceException, e.message
    end
  end
end

# Применение патча через prepend
AccountController.prepend RedmineLdapPasswd::AccountControllerPatch

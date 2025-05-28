module RedmineLdapPasswd
  module AccountControllerPatch
    def change_password
      Rails.logger.warn("LDAP PATCH: change_password override triggered")
      @user = User.current
      unless @user.logged?
        redirect_to signin_path
        return
      end

      if @user.auth_source.is_a?(AuthSourceLdapPasswd)
        if request.post?
          if params[:new_password] != params[:new_password_confirmation]
            flash.now[:error] = l(:notice_new_password_and_confirmation_different)
          elsif !AuthSourceLdapPasswd.is_password_valid(params[:new_password])
            flash.now[:error] = l(:notice_new_password_format)
          else
            result = @user.auth_source.change_user_password(@user, params[:password], params[:new_password])
            if result == true
              flash[:notice] = l(:notice_account_password_updated)
              redirect_to my_account_path
              return
            elsif result.respond_to?(:message)
              flash.now[:error] = result.message
            else
              flash.now[:error] = l(:notice_account_wrong_password)
            end
          end
        end
        render action: 'change_password'
      else
        super
      end
    rescue Net::LDAP::LdapError => e
      raise AuthSourceException, e.message
    end
  end
end

AccountController.prepend RedmineLdapPasswd::AccountControllerPatch
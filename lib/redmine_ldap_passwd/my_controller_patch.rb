module RedmineLdapPasswd
  module MyControllerPatch
    def password
      @user = User.current

      unless @user.change_password_allowed?
        flash[:error] = l(:notice_can_t_change_password)
        redirect_to my_account_path
        return
      end

      if request.post?
        if !@user.check_password?(params[:password])
          flash.now[:error] = l(:notice_account_wrong_password)
        elsif params[:password] == params[:new_password]
          flash.now[:error] = l(:notice_new_password_must_be_different)
        elsif params[:new_password_confirmation] != params[:new_password]
          flash.now[:error] = l(:notice_new_password_and_confirmation_different)
        elsif AuthSourceLdapPasswd.change_password_allowed?(@user)
          if AuthSourceLdapPasswd.is_password_valid(params[:new_password])
            r = @user.auth_source.change_user_password(@user, params[:password], params[:new_password])

            if r == true
              session[:ctime] = User.current.passwd_changed_on.utc.to_i
              flash[:notice] = l(:notice_account_password_updated)
              redirect_to my_account_path
            elsif r == false
              super
            else
              flash.now[:error] = r.message
            end
          else
            flash.now[:error] = l(:notice_new_password_format)
          end
        else
          super
        end
      end
    rescue Net::LDAP::LdapError => e
      raise AuthSourceException.new(e.message)
    end
  end
end

# prepend patch
MyController.prepend RedmineLdapPasswd::MyControllerPatch

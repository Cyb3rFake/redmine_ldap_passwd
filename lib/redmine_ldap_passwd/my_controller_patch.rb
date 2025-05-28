module RedmineLdapPasswd
  module MyControllerPatch
    def self.included(base)
      base.class_eval do
        unloadable

        alias_method :password_without_ldap_patch, :password
        alias_method :password, :password_with_ldap_patch
      end
    end

    def password_with_ldap_patch
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
        elsif params[:new_password] != params[:new_password_confirmation]
          flash.now[:error] = l(:notice_new_password_and_confirmation_different)
        elsif !AuthSourceLdapPasswd.change_password_allowed?(@user)
          password_without_ldap_patch
        elsif !AuthSourceLdapPasswd.is_password_valid(params[:new_password])
          flash.now[:error] = l(:notice_new_password_format)
        else
          result = @user.auth_source.change_user_password(@user, params[:password], params[:new_password])
          if result == true
            session[:ctime] = User.current.passwd_changed_on&.utc&.to_i
            flash[:notice] = l(:notice_account_password_updated)
            redirect_to my_account_path
          elsif result == false
            password_without_ldap_patch
          else
            flash.now[:error] = result.message
          end
        end
      end
    rescue Net::LDAP::LdapError => e
      raise AuthSourceException, e.message
    end
  end
end
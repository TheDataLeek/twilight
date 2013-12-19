# Helper to facilitate user interactions
module SessionsHelper
    # Sign the user in (deal with db)
    def sign_in(user)
        remember_token = User.new_remember_token
        cookies.permanent[:remember_token] = remember_token
        user.update_attribute(:remember_token, User.encrypt(remember_token))
        self.current_user = user
    end

    # Establish user state
    def signed_in?
        !current_user.nil?
    end

    # Set current user
    def current_user=(user)
        @current_user = user
    end

    # Get current user and set
    def current_user
        remember_token  = User.encrypt(cookies[:remember_token])
        @current_user ||= User.find_by(remember_token: remember_token)
    end

    # Help establish user state
    def current_user?(user)
        user == current_user
    end

    # User state
    def signed_in_user
        unless signed_in?
            store_location
            redirect_to signin_url, notice: "Please sign in."
        end
    end

    # Sign the user out
    def sign_out
        self.current_user = nil
        cookies.delete(:remember_token)
    end

    # User redirects
    def redirect_back_or(default)
        redirect_to(session[:return_to] || default)
        session.delete(:return_to)
    end

    # Save location for returns
    def store_location
        session[:return_to] = request.url if request.get?
    end
end

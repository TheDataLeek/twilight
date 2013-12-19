# Handle SignIn and Signout processes
class SessionsController < ApplicationController
    # Placeholder
    def new
    end

    # Sign in the user (create a user session)
    def create
        # If signed in user attempts to signin again
        if !self.current_user.nil?
            # redirect to their homepage
            redirect_to self.current_user
        else
            # Query db for authentication
            user = User.find_by(email: params[:session][:email].downcase)
            # If valid sign in
            if user && user.authenticate(params[:session][:email], params[:session][:password])
                sign_in user
                redirect_back_or user
            else
                flash[:error] = 'Invalid email/password combination'
                redirect_to login_url
            end
        end
    end

    # Sign the user out (destroy the user session)
    def destroy
        sign_out
        redirect_to root_url
    end
end

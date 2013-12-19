# Control user interactions, show, index, etc.
class UsersController < ApplicationController
    # We don't want index page. Redirect away from it.
    def index
        if signed_in?
            redirect_to user_path(self.current_user)
        else
            redirect_to root_url
        end
    end

    # Creates a new user record
    def create
        @user = User.new(user_params)
        if @user.valid?
            # Score hasn't been established yet, but nil is bad
            @user.score = 0
            @user.save
            sign_in @user
            redirect_to @user
            # Add username to watched file in order to update info
            File.open('./watch/get_users.txt', 'a') { |file| file.puts('%s' % @user.username) }
        else
            flash[:error] = ["Sorry, we couldn't create your account because of the following error(s):"]
            @user.errors[:username].each do |e|
                flash[:error] << "Username " + e
            end
            @user.errors[:email].each do |e|
                flash[:error] << "Email " + e
            end
            @user.errors[:password].each do |e|
                flash[:error] << "Password " + e
            end
            redirect_to signup_path
        end
    end

    # Create a new user. Not really important...
    def new
        @user = User.new
    end

    # Redirect to update info
    def edit
        # Add to watchdog file
        File.open('./watch/get_users.txt', 'a') { |file| file.puts('%s' % self.current_user.username) }
        redirect_to show
    end

    # Show the user homepage
    def show
        # If given id params, use that user
        user = User.find(params[:id])
        if user.nil?
            @user = self.current_user
        else
            @user = user
        end
    end

    # Update... Not used. Edit used instead.
    def update
        if @user.update_attributes(user_params)
            flash[:notice] = "Query Sent. Information will be updated soon."
            redirect_to @user
        else
            render 'edit'
        end
    end

    # Again, not used. Placeholder for implementation
    def destroy
        User.find(params[:id]).destroy
        flash[:success] = "User destroyed."
        redirect_to root_url
    end

    private
        def user_params
            params.require(:user).permit(:username, :email, :password,
                                         :password_confirmation)
        end
end

class UsersController < ApplicationController
    def index
        if signed_in?
            redirect_to user_path(self.current_user)
        else
            redirect_to root_url
        end
    end

    def create
        @user = User.new(user_params)
        if @user.valid?
            @user.score = 0
            @user.save
            sign_in @user
            redirect_to @user
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

    def new
        @user = User.new
    end

    def edit
        File.open('./watch/get_users.txt', 'a') { |file| file.puts('%s' % self.current_user.username) }
        redirect_to show
    end

    def show
        @user = self.current_user
    end

    def update
        if @user.update_attributes(user_params)
            flash[:notice] = "Query Sent. Information will be updated soon."
            redirect_to @user
        else
            render 'edit'
        end
    end

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

class UsersController < ApplicationController
    def index
    end

    def create
        p user_params
        @user = User.new(user_params)
        if @user.valid?
            @user.score = 0
            @user.save
            sign_in @user
            redirect_to @user
            File.open('./watch/get_users.txt', 'a') { |file| file.puts('%s' % @user.username) }
        else
            flash[:error] = "Something's Wrong. Please double check fields."
            render 'new'
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
            flash[:success] = "User updated"
            redirect_to @user
        else
            render 'edit'
        end
    end

    def destroy
        User.find(params[:id]).destroy
        flash[:success] = "User destroyed."
        redirect_to users_url
    end

    private
        def user_params
            params.require(:user).permit(:username, :email, :password,
                                         :password_confirmation)
        end
end

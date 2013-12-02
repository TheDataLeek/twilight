class UsersController < ApplicationController
    def index
    end

    def create
        @user = User.new(user_params)
        p @user
        @user.save
        sign_in @user
        redirect_to @user
    end

    def new
        @user = User.new
    end

    def edit
    end

    def show
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

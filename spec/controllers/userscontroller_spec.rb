require "spec_helper"

describe UsersController do
    describe "POST #create" do
        it "creates a new user" do
            params = {:username => "tester",
                      :email => "tester@test.com",
                      :password => "asdasdasd",
                      :password_confirmation => "asdasdasd"}
            @testuser = User.new(params)
            post :create, :user_params => params
        end
        it "adds the user if valid"
        it "flashes error if invalid entry"
    end

    describe "GET #show" do
        it "establishes current user" do
            get :show
            @user.should_not == nil
        end
    end
end

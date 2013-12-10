require "spec_helper"

describe UsersController do
    describe "POST #create" do
        it "creates a new user with valid input" do
            params = {:username => "tester",
                      :email => "tester@test.com",
                      :password => "asdasdasd",
                      :password_confirmation => "asdasdasd"}

            get :new
            post :create, :user => params

            User.find_by(username: "tester").username.should == "tester"
        end

        it "does nothing with invalid input" do
            params = {:username => "tester_bad",
                      :email => "tester",
                      :password => "asd",
                      :password_confirmation => "asd"}

            get :new
            post :create, :user => params

            User.find_by(username: "tester_bad").should == nil
        end
    end
end

require 'spec_helper'

describe RankingController do
    describe "GET show" do
        it "constructs friends and followers arrays" do
            @user = User.new(:username => "tester",
                             :score => 100)
        end
    end
end

class RankingController < ApplicationController
    def show
        @user = self.current_user
        @followers = Array.new
        @followers << @user
        Followers.find_each do |follower|
            entered_user = User.find_by userid: follower.user
            if entered_user.nil?
                follow_user = User.new(:username=>follower.user, :score=>1)
            else
                follow_user = entered_user
            end
            @followers << follow_user
        end
    end
end

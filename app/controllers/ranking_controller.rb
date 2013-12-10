class RankingController < ApplicationController
    def show
        @user = self.current_user

        @followers = Array.new
        @friends = Array.new

        @followers << @user
        @friends << @user

        Followers.find_each do |follower|
            entered_user = User.find_by userid: follower.user
            if entered_user.nil?
                follow_user = User.new(:username=>follower.user, :score=>0)
            else
                follow_user = entered_user
            end
            if follower.follows == @user.userid
                @followers << follow_user
            end
        end
        Followers.find_each do |follower|
            entered_user = User.find_by userid: follower.follows
            if entered_user.nil?
                follow_user = User.new(:username=>follower.follows, :score=>0)
            else
                follow_user = entered_user
            end
            if follower.user == @user.userid
                @friends << follow_user
            end
        end
        @followers.sort_by!{|e| -e[:score]}
        @friends.sort_by!{|e| -e[:score]}
    end
end

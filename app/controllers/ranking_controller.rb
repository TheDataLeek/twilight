class RankingController < ApplicationController
    def show
        @user = self.current_user

        @followers = Array.new
        @friends = Array.new

        @followers << @user
        @friends << @user

        # Followers
        Followers.where(follows: @user.userid).each do |follower|
            entered_user = User.find_by(userid: follower.user)
            if entered_user.nil?
                follow_user = User.new(:username=>follower.user, :score=>0)
            else
                follow_user = entered_user
            end
            @followers << follow_user
        end

        # Friends
        Followers.where(user: @user.userid).each do |follower|
            entered_user = User.find_by userid: follower.follows
            if entered_user.nil?
                follow_user = User.new(:username=>follower.follows, :score=>0)
            else
                follow_user = entered_user
            end
            @friends << follow_user
        end

        # Order
        @followers.sort_by!{|e| -e[:score]}
        @friends.sort_by!{|e| -e[:score]}
    end
end

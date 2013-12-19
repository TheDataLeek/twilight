# == Ranking Controller for user ranks
# matched when a user logs in and navigates to /rankings
class RankingController < ApplicationController
    # The only method, to show the rankings
    def show
        @user = self.current_user

        # Create empty arrays to be populated
        @followers = Array.new
        @friends = Array.new

        # Make sure current user in in list for comparisons
        @followers << @user
        @friends << @user

        # Get Followers
        Followers.where(follows: @user.userid).each do |follower|
            # Attempt to locate existing user in db
            entered_user = User.find_by(userid: follower.user)
            # If the user doesn't exist, just use id
            if entered_user.nil?
                follow_user = User.new(:username=>follower.user, :score=>0)
            else
                follow_user = entered_user
            end
            @followers << follow_user
        end

        # Get Friends
        Followers.where(user: @user.userid).each do |follower|
            # Attempt to locate existing user in db
            entered_user = User.find_by userid: follower.follows
            # If the user doesn't exist, just use id
            if entered_user.nil?
                follow_user = User.new(:username=>follower.follows, :score=>0)
            else
                follow_user = entered_user
            end
            @friends << follow_user
        end

        # Order the arrays reverse, highest at top
        @followers.sort_by!{|e| -e[:score]}
        @friends.sort_by!{|e| -e[:score]}
    end
end

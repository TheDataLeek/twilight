class RankingController < ApplicationController
    def show
        @user = self.current_user
        @followers = Array.new
        @followers << @user
        Followers.find_each do |from|
            @followers << from
        end
    end
end

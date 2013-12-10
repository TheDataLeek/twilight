class StaticPagesController < ApplicationController
    def login
    end

    def logout
    end

    def about
        @users = User.all
        @users.sort_by!{|e| -e[:score]}
    end
end

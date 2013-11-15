class RankingController < ApplicationController
    def index
        @nav = render_navigation(:level => :all)
        p @nav
    end

    def login
        @nav = render_navigation(:level => :all)
    end
end

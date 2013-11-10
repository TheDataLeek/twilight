class RankingController < ApplicationController
    def index
      @nav = render_navigation(:level => :all)
      p @nav
    end

    def login
        p "Not Implemented"
    end
end

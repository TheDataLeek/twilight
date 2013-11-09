class RankingController < ApplicationController
    def index
      @nav = render_navigation(:level => :all)
    end

    def login
        p "Not Implemented"
    end
end

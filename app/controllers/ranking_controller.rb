class RankingController < ApplicationController
  def index
      @nav = render_navigation(:level => :all)
  end
end

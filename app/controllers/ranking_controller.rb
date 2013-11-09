class RankingController < ApplicationController
  def index
    page1      = Page.new
    page1.name = "test1"
    page1.url  = "google.com"
    page2      = Page.new
    page2.name = "test2"
    page2.url  = "reddit.com"
    @pages     = [page1, page2]
  end

  class Page
    @name = nil
    @url = nil
    def name=(value)
      @name = value
    end
    def name
      @name
    end
    def url=(value)
      @url= value
    end
    def url
      @url
    end
  end
end

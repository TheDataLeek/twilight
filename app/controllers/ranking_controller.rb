class RankingController < ApplicationController
  attr_accessor :pages

  add_page("Index", "/")
  def index
  end

  def add_page(pname, purl)
    new_page      = Page.new
    new_page.name = pname
    new_page.url  = purl
    @pages << new_page
  end

  class Page
    attr_accessor :url,:name
  end
end

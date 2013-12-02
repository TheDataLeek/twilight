class StaticPagesController < ApplicationController
    def login
    end

    def logout
    end

    def about
        @about  = "/static_pages/about"
        @login  = "/static_pages/login"
        @logout = "/static_pages/logout"
    end
end

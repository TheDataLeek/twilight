class ApplicationController < ActionController::Base
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception

    def index
        @nav = render_navigation(:level => :all)
    end

    def login
        @nav = render_navigation(:level => :all)
    end
end

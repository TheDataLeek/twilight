class StaticPagesController < ApplicationController
    def login
    end

    def logout
    end

    def about
        @users = User.all
        @users.sort_by!{|e| -e[:score]}

        jsonfile = {"name"=>"Users",
                      "children"=>Array.new}
        @users.each do |u|
            user =  {"name"=>u.username,
                     "size"=>2000}
            children = Array.new
            Followers.where(user:u.userid).each do |f|
                followuser = User.find_by(userid: f.follows)
                if followuser.nil?
                    name = f.follows
                else
                    name = followuser.username
                end
                children << {"name"=>name,
                                     "size"=>2000}
            end
            if children != []
                user["children"] = children
            end
            jsonfile['children'] << user
        end

        File.open("public/network.json","w") do |f|
            f.write(jsonfile.to_json)
        end

    end
end

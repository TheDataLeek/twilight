# Static Pages controller. Mostly boring save json network file.
class StaticPagesController < ApplicationController
    # Placeholder
    def login
    end

    # Placeholder
    def logout
    end

    # Display the "about" page, or the homepage
    def about
        # Get users to display in table
        @users = User.all
        @users.sort_by!{|e| -e[:score]}

        # Establish root node of our user array
        jsonfile = {"name"=>"Users",
                      "children"=>Array.new}
        # Iterate users and add to root node
        @users.each do |u|
            user =  {"name"=>u.username,
                     "size"=>2000}
            children = Array.new
            # Iterate follower table and get a list of child nodes
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
            # We don't want an empty children array, this will lead to badness
            if children != []
                user["children"] = children
            end
            # After user is done, add to root node
            jsonfile['children'] << user
        end

        # Write hash as json to file
        File.open("public/network.json","w") do |f|
            f.write(jsonfile.to_json)
        end
    end

    # Placeholder
    def math
    end
end

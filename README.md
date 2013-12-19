README
======
Twilight is a tool to rank twitter users on their influence. This tool is
intended to run as a Ruby on Rails website that allows users to determine their
influence ranking based on several different factors. This can be run as a full
fledged Ruby on Rails website, or just as a exectuable Python program located
in /bin.

The languages used are Ruby on Rails and Python.

Models
------
* User
  * id:int:primary key    -- Unique Twitter ID
  * username:string       -- Unique Twitter Name
  * name:string           -- Non-Unique Name
  * created:time          -- Profile Creation Date
  * rank:int              -- Social Network Rank
  * score:int             -- Total Score
  * favourite_count:int   -- Favourite Count
  * follower_count:int    -- Follower Count
  * friend_count:int      -- Friend Count
  * retweet_count:int     -- Retweet Count
  * statuses_count:int    -- Statuses Count
  * email:string          -- Email String
  * password:string       -- Password
  * password_hash:string  -- PassHash
  * password_salt:string  -- PassSalt
  * remember_token:string -- Remember Token
* Followers
  * id:int:primary key   -- ID
  * user:int:foreign key -- User
  * follows:int          -- User being Followed
* Friends
  * id:int:primary key   -- User ID
  * user:int:foreign key -- User it References
* Retweets
  * id:int:primary key   -- User ID
  * user:int:foreign key -- User it References
* Network
  * id:int:primary key   -- User ID
  * user:int:foreign key -- User it References

Deployment
----------
    git add -A
    git commit -m <message>
    git push -u origin master
    bundle exec cap production deploy
    ssh will-farmer.com
    cd <webdir>/current
    rake assets:precompile
    cp <old release>/db/production <current>/db/production
    vim about.html # change json pathing
    ta 3
    cd <current>
    cp <old release>/config/gmail_credentials.txt <current>/config/gmail_credentials.txt
    ./bin/watcher.py
    cd public
    mkdir javascripts
    cp blackhash* blackhash.jpg
    cp <js>*js javascripts
    vim ./bin/watcher.py # change db
    apache2 restart

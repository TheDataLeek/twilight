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
  * id:int:primary key   -- Unique Twitter ID
  * screen_name:string   -- Unique Twitter Name
  * name:string          -- Non-Unique Name
  * created:time         -- Profile Creation Date
  * rank:int             -- Social Network Rank
  * score:int            -- Total Score
  * favourite_count:int  -- Favourite Count
  * follower_count:int   -- Follower Count
  * friend_count:int     -- Friend Count
  * retweet_count:int    -- Retweet Count
  * statuses_count:int   -- Statuses Count
* Followers
  * id:int:primary key   -- User ID
  * user:int:foreign key -- User it References
* Friends
  * id:int:primary key   -- User ID
  * user:int:foreign key -- User it References
* Retweets
  * id:int:primary key   -- User ID
  * user:int:foreign key -- User it References
* Network
  * id:int:primary key   -- User ID
  * user:int:foreign key -- User it References

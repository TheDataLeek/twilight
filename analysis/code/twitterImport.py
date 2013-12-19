#!/usr/bin/env python

import sys
import json
import ast
import requests, requests_oauthlib
import sqlite3

# Twitter Authentication Info
auth = requests_oauthlib.OAuth1("rAco7WbMOYuvsiln7SLbHw",
                                "Hlj3CVuLxRMiFzOo9RqhNYBxdB1F6ka5G3J52IDdw",
                                "371062566-ZPmyuoUkbcrwN5jTrTTX5dTWTl07g1yVX8XenBxI",
                                "7GFOWv7JoyUipfgxdkAIEMoE9FMRHbNc7GKFF3eK0SM")


def gen_database(limit, database, run):
    '''
    Create the database
    '''
    print("Creating Database")
    # Limit to English around Boulder, CO
    data       = {'language':'en', 'geocode':'40,105,50mi'}
    # Stream URL
    response   = requests.get('https://stream.twitter.com/1.1/statuses/sample.json',
                                params=data, auth=auth, stream=True)
    connection = sqlite3.connect(database)
    cursor     = connection.cursor()
    try:  # Try to create tables, and if failed, just add to them
        cursor.execute("""CREATE TABLE users(
                            id TEXT PRIMARY KEY NOT NULL,
                            name TEXT NOT NULL,
                            followers TEXT,
                            favourites_count INT,
                            followers_count INT,
                            friends_count INT)""")
        cursor.execute("""CREATE TABLE posts(
                            id TEXT PRIMARY KEY NOT NULL,
                            time TEXT,
                            entities TEXT,
                            user TEXT)""")
        cursor.execute("""CREATE TABLE retweets(
                            id TEXT,
                            end TEXT,
                            count INT)""")
    except sqlite3.OperationalError:  # If tables exist, don't create them
        pass
    if run:
        try:
            while True:
                add_process(limit, response, cursor, connection)
        except KeyboardInterrupt:
            print("Stopping")
    else:
        add_process(limit, response, cursor, connection)
        print("Stopping")

    connection.close()


def add_process(limit, response, cursor, connection):
    posts = take(limit, response)                   # Get posts from stream
    add_post_users(posts, cursor, connection)       # Add posts and users
    add_mentioned_users(posts, cursor, connection)  # Add all mentioned users
    update_retweet_count(posts, cursor, connection) # Updates Retweets
    update_user_info(connection, cursor)            # Update mentioned profiles if missing
    connection.commit()                             # Update DB with results


def update_retweet_count(posts, cursor, connection):
    ''' Updates retweet count '''
    for post in posts:
        start = int(post['user']['id'])
        ends  = post['entities']['user_mentions']
        for end in ends:
            exist_check = cursor.execute("SELECT id FROM retweets WHERE id=?", (start,)).fetchone()
            if exist_check is None:
                cursor.execute("INSERT INTO retweets (id, end, count) VALUES (?, ?, ?)", (start, end['id'], 1))
            else:
                cursor.execute("UPDATE retweets SET count=count + 1 WHERE id=? AND end=?", (start, end['id']))


def take(n, response):
    ''' Return array of n tweets '''
    posts = []
    grabbed = [post for post in get_post(response, n)]
    for post in grabbed:
        clean               = {}
        clean['id']         = post['id']
        clean['created_at'] = post['created_at']
        clean['entities']   = post['entities']
        clean['userid']     = post['user']['id']
        clean['user']       = post['user']
        posts.append(clean)
    return posts


def get_post(response, limit):
    ''' JUST YIELDS RETWEETS '''
    count = 0
    for line in response.iter_lines():
        try:
            post = json.loads(line.decode('utf-8'))
            if post['text'].startswith('RT'):
                yield post
            count += 1
            if count > limit:
                break
            elif count % 100 == 0:
                print(count)
        except:
            print(line)

def add_post_users(posts, cursor, connection):
    count = 0                      # Progress bar
    for post in posts:
        count += 1
        if count % 10000 == 0:  # Progress Bar
            connection.commit()
            print(count)
        exist_check = cursor.execute("SELECT id FROM posts WHERE id=?", (post['id'],)).fetchone()
        user_check = cursor.execute("SELECT id FROM users WHERE id=?", (post['userid'],)).fetchone()
        if exist_check is None:
            add_to_posts(cursor, post)
        if user_check is None:
            add_to_users(cursor, post['user'])


def add_to_posts(cursor, post):
    values = (post['id'], post['created_at'], str(post['entities']), post['userid'])
    cursor.execute("INSERT INTO posts (id,time,entities,user) VALUES (?,?,?,?)", values)


def add_to_users(cursor, user):
    values = (user['id'], user['screen_name'], '[]', user['favourites_count'], user['followers_count'], user['friends_count'])
    cursor.execute("INSERT INTO users (id,name,followers,favourites_count,followers_count,friends_count) VALUES (?,?,?,?,?,?)", values)


def add_mentioned_users(posts, cursor, connection):
    count = 0                      # Progress bar
    for post in posts:
        count += 1
        if count % 10000 == 0:  # Progress Bar
            connection.commit()
            print(count)
        for user in post['entities']['user_mentions']:
            user_check = cursor.execute("SELECT id FROM users WHERE id=?", (user['id'],)).fetchone()
            if user_check is None:
                values = (user['id'], user['screen_name'])
                cursor.execute("INSERT INTO users (id,name) VALUES (?,?)", values)


def update_user_info(connection, cursor):
    print("Fixing Profile Information")
    update = connection.cursor()
    names  = []
    count  = 0

    def update_one_user(update, profile):
        update.execute("""UPDATE users SET friends_count=?,
                                         followers_count=?,
                                         favourites_count=?,
                                         followers=?
                             WHERE id=?""",
                                        (profile['friends_count'],
                                         profile['followers_count'],
                                         profile['favourites_count'],
                                         '[]',
                                         profile['id']))

    for user in cursor.execute("SELECT * FROM users WHERE followers_count IS NULL").fetchall():
        if len(names) >= 100:
            profiles = get_profile(names)
            for profile in profiles:
                update_one_user(update, profile)
            names = []
            if profiles is None:
                break
        else:
            names.append(user[1])
    if names != []:
        profiles = get_profile(names)
        for profile in profiles:
            update_one_user(update, profile)
    connection.commit()


def add_followers(connection, cursor):
    print("	Updating Followers")
    update = connection.cursor()
    for user in cursor.execute("SELECT * FROM users WHERE followers='[]'"):
        followers = get_followers(user[1])
        if followers is None:
            break
        elif followers:
            update.execute("""UPDATE users SET followers=?  WHERE id=?""",
                                            (str(followers), user[0]))
            connection.commit()
    return cursor.execute("SELECT * FROM users WHERE followers='[]'").fetchall()


def get_followers(screen_name):
    '''
    Get user followers. This is limited by Twitter's OAuth rate limiting. 15 requests/15 minutes
    '''
    data = {'screen_name':screen_name}
    response = requests.get('https://api.twitter.com/1.1/followers/ids.json', params=data, auth=auth)
    try:
        followers = response.json()["ids"]
    except KeyError:
        print(response.json())
        code = response.json()["errors"][0]["code"]
        if code == 34:
            return False
        elif code == 88:
            print('Follower Overload. Stopping')
            return None
        else:
            print('Something\'s wrong. Investigate.')
            return None
    return followers

def get_profile(names):
    joined_names = ','.join(names)
    data         = {'screen_name':joined_names}
    response     = requests.get('https://api.twitter.com/1.1/users/lookup.json', params=data, auth=auth)
    profile      = response.json()
    try:
        profile[0]['screen_name']
    except:
        print('Profile Overload. Stopping')
        return None
    return profile

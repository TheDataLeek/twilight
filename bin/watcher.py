#!/usr/bin/env python2.7

import sys, os
import logging
import time
import smtplib
import watchdog
import sqlite3
from watchdog.observers import Observer
from watchdog.events import LoggingEventHandler
from watchdog.events import FileSystemEventHandler

from get_user import *
from rank_user import *


fromaddr    = 'TwilightRanker@gmail.com'
toaddrs     = ['willzfarmer@gmail.com', 'da007penguin@gmail.com']
credentials = open('./config/gmail_credentials.txt')
username    = credentials.readline()[:-1]
password    = credentials.readline()[:-1]


def main():
    #open('./log/pyRank.log', 'w').close()  # Testing only. Delete for prod
    logging.basicConfig(filename='./log/pyRank.log',
                        level=logging.DEBUG,
                        format='%(levelname)s\t|\t%(asctime)s\t-\t %(message)s')
    logging.info("Program Start")
    start_watchdog()


def start_watchdog():
    event_handler = RankingHandler()
    observer      = Observer()
    log_handler   = LoggingEventHandler()
    log_observer  = Observer()
    try:
        observer.schedule(event_handler, path='./watch')
        observer.start()
        log_observer.schedule(log_handler, path='./watch')
        log_observer.start()
        logging.info("Watching Directory")
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        logging.info("Kill message sent. Aborting")
        observer.stop()
        log_observer.stop()
    except:
        logging.info("Unexpected error: %s" % sys.exc_info()[0])

        observer.stop()
        log_observer.stop()

        error_message(sys.exc_info()[0])

    observer.join()
    log_observer.join()


def error_message(error, msg=None):
    # Send Email
    if not msg:
        msg = "Unexpected error: %s\nRanking Script Failed. Please log in and restart manually\n\nEd, this is probably your fault..." % error
    for receiver in toaddrs:
        server = smtplib.SMTP('smtp.gmail.com:587')
        server.starttls()
        server.login(username,password)
        server.sendmail(fromaddr, receiver, msg)
        server.quit()


class RankingHandler(FileSystemEventHandler):
    def __init__(self):
        self.modified     = False
        self.last_checked = time.time()
        self.time_gap     = None
        self.missed       = []
        self.users        = None

    def on_any_event(self, event):
        self.modified = True
        self.time_gap = time.time() - self.last_checked
        if self.time_gap >= 5: #900:
            self.last_checked = time.time()
            logging.info("User Import Initiating at %s" % str(self.last_checked))
            try:
                users       = open('./watch/get_users.txt', 'r')
                user_list   = users.read()[:-1].split('\n')
                users.close()
                if user_list == ['']:
                    return
                logging.info("Users: %s" % str(user_list))
                try:
                    cursor      = user_list[0:15]
                    self.missed = user_list[15:len(user_list)]
                except IndexError:
                    cursor = user_list[0:len(user_list)]
                self.users = get_profile(cursor)
                previous_user = None
                for i in range(len(self.users)):
                    user                       = self.users[i]
                    if user['id'] != previous_user:
                        print(user['screen_name'])
                        self.users[i]['followers'] = get_followers(user['screen_name'])
                        self.users[i]['friends']   = get_friends(user['screen_name'])
                        self.users[i]['score']     = calculate_score(user)
                    previous_user = user['id']
                logging.info("Missed %s. Writing back to file" % str(self.missed))
                self.write_acquired()
                self.write_missed()
            except IOError:
                error_message(sys.exc_info()[0], msg="Misaligned I/O... Probably not an issue, but someone should probably check it out...")

    def write_missed(self):
        os.remove("./watch/get_users.txt")
        get_user_file = open('./watch/get_users.txt', 'w')
        for user in self.missed:
            get_user_file.write(user + '\n')
        get_user_file.close()
        logging.info("File Cleaned")

    def write_acquired(self):
        connection = sqlite3.connect('./db/development.sqlite3')
        cursor     = connection.cursor()
        logging.info("Connected to Database")
        for user in self.users:
            logging.info("	Updating %i" % user['id'])
            cursor.execute('''UPDATE users SET userid=?,
                                               created=?,
                                               score=?,
                                               favourite_count=?,
                                               follower_count=?,
                                               friend_count=?,
                                               statuses_count=?,
                                               userimage=?
                                WHERE username=? COLLATE NOCASE''',
                                                       (user['id'],
                                                        user['created_at'],
                                                        user['score'],
                                                        user['favourites_count'],
                                                        user['followers_count'],
                                                        user['friends_count'],
                                                        user['statuses_count'],
                                                        user['profile_image_url'],
                                                        user['screen_name']))
            connection.commit()
        logging.info("Users Updated")
        self.users = []
        try:
            followers = user['followers']['ids']
            for follower in followers:
                logging.info("	Adding %i -> %i" % (user['id'], follower))
                exists = cursor.execute('''SELECT *
                                            FROM followers
                                            WHERE user=? AND follows=?''',
                                            (follower, user['id'])).fetchall()
                if not exists:
                    cursor.execute('''INSERT INTO followers (follows, user)
                                            VALUES (?, ?)''', (user['id'],
                                                            follower))
            logging.info("Followers Updated")
            connection.commit()
        except:
            logging.debug("FOLLOWER OVERLOAD")
        try:
            friends = user['friends']['users']
            for frienduser in friends:
                friend = frienduser['id']
                logging.info("	Adding %i -> %i" % (friend, user['id']))
                exists = cursor.execute('''SELECT * FROM followers
                                            WHERE user=? AND follows=?''',
                                            (user['id'], friend)).fetchall()
                if not exists:
                    cursor.execute('''INSERT INTO followers (user, follows)
                                            VALUES (?, ?)''', (user['id'],
                                                               friend))
            logging.info("Followers Updated")
            connection.commit()
        except:
            logging.debug("FRIEND OVERLOAD")

if __name__ == "__main__":
    sys.exit(main())

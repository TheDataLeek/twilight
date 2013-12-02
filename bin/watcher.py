#!/usr/bin/env python

import sys
import logging
import time
import smtplib
import watchdog
from watchdog.observers import Observer
from watchdog.events import LoggingEventHandler
from watchdog.events import FileSystemEventHandler

from get_user import *
from rank_user import *


fromaddr    = 'TwilightRanker@gmail.com'
toaddrs     = ['willzfarmer@gmail.com', 'da007penguin@gmail.com']
credentials = open('../config/gmail_credentials.txt')
username    = credentials.readline()[:-1]
password    = credentials.readline()[:-1]


def main():
    open('../log/pyRank.log', 'w').close()  # Testing only. Delete for prod
    logging.basicConfig(filename='../log/pyRank.log',
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
        observer.schedule(event_handler, path='../watch')
        observer.start()
        log_observer.schedule(log_handler, path='../watch')
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

    def on_any_event(self, event):
        self.modified = True
        self.time_gap = time.time() - self.last_checked
        if self.time_gap >= 5: #900:
            self.last_checked = time.time()
            try:
                users = open('../watch/get_users.txt', 'r').read()
                print(users)
            except IOError:
                error_message(sys.exc_info()[0], msg="Misaligned I/O")


if __name__ == "__main__":
    sys.exit(main())

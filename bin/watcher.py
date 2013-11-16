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
    event_handler = FileSystemEventHandler()
    observer      = Observer()
    observer.schedule(event_handler, path='../watch')
    observer.start()
    log_handler   = LoggingEventHandler()
    log_observer  = Observer()
    log_observer.schedule(log_handler, path='../watch')
    log_observer.start()
    try:
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

        # Send Email
        msg = "Unexpected error: %s\nScript Failed. Please log in and restart manually" % sys.exc_info()[0]
        for receiver in toaddrs:
            server = smtplib.SMTP('smtp.gmail.com:587')
            server.starttls()
            server.login(username,password)
            server.sendmail(fromaddr, receiver, msg)
            server.quit()
    observer.join()
    log_observer.join()


if __name__ == "__main__":
    sys.exit(main())

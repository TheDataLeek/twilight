#!/usr/bin/env python

import logging
import time
import watchdog
import sys
from watchdog.observers import Observer
from watchdog.events import LoggingEventHandler

def main():
    open('../log/pyRank.log', 'w').close()  # Testing only. Delete for prod
    logging.basicConfig(filename='../log/pyRank.log',
                        level=logging.DEBUG,
                        format='%(levelname)s\t|\t%(asctime)s\t-\t %(message)s')
    logging.info("Program Start")

    event_handler = LoggingEventHandler()
    observer      = Observer()
    observer.schedule(event_handler, path='../watch')
    observer.start()
    try:
        logging.info("Watching Directory")
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        logging.info("Kill message sent. Aborting")
        observer.stop()
    except:
        logging.info("Unexpected error: %s" % sys.exc_info()[0])
        raise
    observer.join()


if __name__ == "__main__":
    sys.exit(main())

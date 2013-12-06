#!/usr/bin/env python

import sys, os
import argparse
import subprocess
import numpy, scipy
import matplotlib, matplotlib.pyplot as plt
import networkx
from twitterImport import *


def main():
    args = get_args()
    if args.skip:          # If user requested that data be accrued
        print("Generation Database")
        gen_database(args.posts, args.database, args.run)
    else:
        print("Skipping database generation. Assuming database exists")
    edges = clean_database(args)   # Ditch all pairs and gen new db
    #visualize(edges)
    analyze(args)          # Execute R code


def clean_database(args):
    '''
    Remove all pairs from the database, and move into a new one
    '''
    print("Cleaning Database (Stripping Pairs and Creating clean_%s)"
            % args.database)
    connection         = sqlite3.connect(args.database)                                  # Connect to old database
    cursor             = connection.cursor()                                             # Cursor for old execution
    clean_users, edges = get_clean_users(cursor)                                         # Get a dict of clean users
    print("	%i Important Users" % len(clean_users))
    clean_connection   = sqlite3.connect("clean_" + args.database)                  # Connect to new clean database
    clean              = clean_connection.cursor()                                  # Cursor for new clean database
    if args.clean:
        print("Using Existing Clean Database: %s" % "clean_" + args.database)
        output = add_followers(clean_connection, clean)
        return edges
    else:
        while True:
            try:                                                                          # Attempt to add tables
                clean.execute("""CREATE TABLE users(
                                        id TEXT PRIMARY KEY NOT NULL,
                                        name TEXT NOT NULL,
                                        followers TEXT,
                                        favourites_count INT,
                                        followers_count INT,
                                        friends_count INT)""")
                clean.execute("""CREATE TABLE retweets(
                                        id TEXT,
                                        end TEXT,
                                        count INT)""")
                break
            except sqlite3.OperationalError:                                              # If the tables exist
                try:
                    clean.execute("DROP TABLE users")
                except sqlite3.OperationalError:                                              # If the tables exist
                    pass
                try:
                    clean.execute("DROP TABLE retweets")
                except sqlite3.OperationalError:                                              # If the tables exist
                    pass
    user_count = 0
    for user in clean_users:                                                      # Iterate each user in clean dict
        user_count += 1
        if user_count % 1000 == 0:
            print("		%i users entered" % user_count)
        details       = cursor.execute("SELECT * FROM users WHERE id=?",
                                        (user,)).fetchone()                       # Grab user from old_users
        user_id       = details[0]
        name          = details[1]
        followers     = details[2]
        favourites    = details[3]
        followcount   = details[4]
        friends       = details[5]
        clean.execute("""INSERT INTO users (id, name, followers,
                                            favourites_count, followers_count,
                                            friends_count) VALUES
                                            (?, ?, ?, ?, ?, ?)""",
                                            (user_id, name, followers,
                                                favourites, followcount,
                                                friends))                         # Insert old user into new table
        for tweet in cursor.execute("SELECT * FROM retweets WHERE end=? OR id=?",
                                        (user,user)).fetchall():                      # Do the same for each retweet
            retweet_id    = tweet[0]
            end           = tweet[1]
            count         = tweet[2]
            clean.execute("""INSERT INTO retweets (id, end, count)
                                VALUES (?, ?, ?)""", (retweet_id, end, count))
    clean_connection.commit()                                                     # Save changes
    output = add_followers(clean_connection, clean)
    if output != []:
        print("----ERROR: NOT ALL EDGES IN PLACE----")
        print(output)
    connection.close()
    clean_connection.close()
    return edges


def get_clean_users(cursor):
    '''
    Return dict of clean users
    '''
    user_scores    = {}
    cleaned_scores = {}
    edges          = []
    for retweet in cursor.execute("SELECT * FROM retweets"):  # Grab all retweets
        dst            = retweet[1]                           # and create dict
        score          = retweet[2]                           # of all user scores
        most_important = dst
        try:
            user_scores[dst] += score
        except KeyError:
            user_scores[dst] = score
    for user in user_scores:                                  # Remove any that
        try:                                                  # have less than 1
            if user_scores[user] > user_scores[most_important]:
                most_important = user
        except KeyError:
            pass
    print("	Getting %s's social network" % most_important)
    cleaned_scores[most_important] = user_scores[most_important]
    retweets = [retweet for retweet in cursor.execute("SELECT * FROM retweets").fetchall()]
    pastsize = 0
    current_size = len(cleaned_scores)
    while pastsize != current_size:
        pastsize = len(cleaned_scores)
        counter = 0
        for retweet in retweets:  # Grab all add to dict all users that
            src     = retweet[0]                                    # Add to dict
            dst     = retweet[1]
            score   = retweet[2]
            try:
                cleaned_scores[dst]
                cleaned_scores[src] = score
                retweets.pop(counter)
                edges.append((src, dst))
                counter -= 1
            except KeyError:
                pass
            counter += 1
        current_size = len(cleaned_scores)
    print("	Full Network Assembled")
    return cleaned_scores, edges


def visualize(edges):
    ''' Create Network Visualization '''
    print("Creating Visualization")
    graph = networkx.DiGraph()
    graph.add_edges_from(edges)
    position = networkx.spectral_layout(graph)
    networkx.draw_networkx_nodes(graph, position, node_size=50)
    networkx.draw_networkx_edges(graph, position)
    plt.savefig("network.svg")


def analyze(args):
    '''
    Run R program and analyze the data
    '''
    print("Executing R program")
    subprocess.call(["Rscript",                             # R execution program
                        "./ranking.R",                      # My R code
                        "%s" % ("clean_" + args.database),  # Using clean_database
                        "%s" % str(args.iterations)])       # Power Method Iterations


def get_args():
    parser = argparse.ArgumentParser(description='Import data')
    parser.add_argument('-d', '--database', type=str, default=None,
                        help='Database to populate')
    parser.add_argument('-s', '--skip', action='store_false',
                        default=True, help='Skip Import')
    parser.add_argument('-p', '--posts', type=int, default=1000,
                        help='Number of posts to load')
    parser.add_argument('-i', '--iterations', type=int, default=2,
                        help='Number of iterations')
    parser.add_argument('-r', '--run', action='store_true',
                        default=False, help='Just run...')
    parser.add_argument('-c', '--clean', action='store_true',
                        default=False, help='User existing clean file?')
    args = parser.parse_args()
    if args.database == None:
        print("Error. Invalid Arguments")
        sys.exit(0)
    return args

if __name__ == '__main__':
    sys.exit(main())

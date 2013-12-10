#!/usr/bin/env python

def calculate_score(user):
    '''
    Ranks user
    '''
    favc = user['favourites_count']
    folc = user['followers_count']
    frdc = user['friends_count']
    score = 6 * favc + 5 * folc + frdc
    return score

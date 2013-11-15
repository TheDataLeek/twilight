#!/usr/bin/env python

import sys
import requests, requests_oathlib

auth = requests_oauthlib.OAuth1("rAco7WbMOYuvsiln7SLbHw",
                                "Hlj3CVuLxRMiFzOo9RqhNYBxdB1F6ka5G3J52IDdw",
                                "371062566-ZPmyuoUkbcrwN5jTrTTX5dTWTl07g1yVX8XenBxI",
                                "7GFOWv7JoyUipfgxdkAIEMoE9FMRHbNc7GKFF3eK0SM")

def get_profile(names):
    joined_names = ','.join(names)
    data = {'screen_name':joined_names}
    response = requests.get('https://api.twitter.com/1.1/users/lookup.json', params=data, auth=auth)
    profile = response.json()
    return profile

def get_followers(screen_name):
    '''
    Get user followers. This is limited by Twitter's OAuth rate limiting. 15 requests/15 minutes
    '''
    data = {'screen_name':screen_name}
    response = requests.get('https://api.twitter.com/1.1/followers/ids.json', params=data, auth=auth)
    return response.json()

def get_friends(screen_name):
    '''
    Get user followers. This is limited by Twitter's OAuth rate limiting. 15 requests/15 minutes
    '''
    data = {'screen_name':screen_name}
    response = requests.get('https://api.twitter.com/1.1/friends/list.json', params=data, auth=auth)
    return response.json()

#!/usr/bin/env python3
# coding: utf-8

## запускать скрипт нужно так > python ./script v.pupkin
## v.pupkin - email пользователя без домена

import os
import csv
import sys
import string
import random
import requests

from sys import argv
filename, unik = argv

TOKEN = 'AgAEA7qhzF35AAYXfYJfAccgq0CYsjFwmJlbdqU'
USER_AGENT = 'Directory Sync Example'

def load_already_created_users():

    params = {
        'fields': 'nickname,id',
	'removed': 'false',
        'per_page': '1000',
    }
    headers = {
        'Authorization': 'OAuth ' + TOKEN,
        'User-Agent': USER_AGENT,
    }
    response = requests.get(
        'https://api.directory.yandex.net/v6/users/',
        params=params,
        headers=headers,
        timeout=20,
    )
    response.raise_for_status()
    response_data = response.json()
    results = response_data['result']
    results = {
        user['id']: user['nickname']
        for user in results
    }
    return results



def change_user_dep(link):

    payload = {
        'department_id': 1,
    }
    headers = {
        'Authorization': 'OAuth ' + TOKEN,
        'User-Agent': USER_AGENT,
    }
    response = requests.patch(
        link,
        json=payload,
        headers=headers,
        timeout=20,
    )
    response.raise_for_status()
    response_data = response.json()
    return response_data['id']

def disable_user(link):
    
    payload = {
        'is_enabled': False,
    }
    headers = {
        'Authorization': 'OAuth ' + TOKEN,
        'User-Agent': USER_AGENT,
    }
    response = requests.patch(
        link,
        json=payload,
        headers=headers,
        timeout=20,
    )
    response.raise_for_status()
    response_data = response.json()
    return response_data['id']

###############################
uid = 0
users = load_already_created_users()

for row in users:
    if users[row] == unik:
        uid = row
if uid == 0:
    raise RuntimeError('Пользователь "{0}" не существует'.format(unik))

link = "https://api.directory.yandex.net/v6/users/{}/".format(uid)
change_user_dep(link)
disable_user(link)


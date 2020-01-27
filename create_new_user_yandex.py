#!/usr/bin/env python3
# coding: utf-8

## запускать скрипт нужно так > python ./script Dimon Batskovich d.batkovich TEST1 male
## Dimon - имя
## Batskovich - фамилия
## d.batkovich - e.mail без домена
## TEST1 - название отдела
## male - пол (male|female)

import os
import csv
import sys
import string
import random
import requests

from sys import argv
filename, ufirst, ulast, unik, udep, sex = argv

TOKEN = 'AgAEA7qhzF35AAYXfYJfAccgq0CYsjFwmJlbdqU'
USER_AGENT = 'Directory Sync Example'

def load_already_created_deps():

    params = {
        'fields': 'name,id',
        'removed': 'false',
        'per_page': '1000',
    }
    headers = {
        'Authorization': 'OAuth ' + TOKEN,
        'User-Agent': USER_AGENT,
    }
    response = requests.get(
        'https://api.directory.yandex.net/v6/departments/',
        params=params,
        headers=headers,
        timeout=20,
    )
    response.raise_for_status()
    response_data = response.json()
    results = response_data['result']
    results = {
        department['id']: department['name']
        for department in results
    }
    return results

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

def create_random_password(length=10):
    symbols = string.ascii_letters + string.digits + '_#$&@!?%'
    return ''.join(
        random.choice(symbols)
        for i in range(length)
    )

def create_user(ufirst, ulast, unik, udep, passwd, deps, users):
# check users    
    a = 'false'
    for row in users:
            if unik == users[row]:
                a = 'true'
    if a == 'true':
        raise RuntimeError('Пользователь "{0}" уже существует'.format(unik))
# check departments
    a = 'false'
    for row in deps:
            if udep == deps[row]:
                a = 'true'
                department_id = row
    if a == 'true':
        print("Mailbox: ", unik,"@belitsoft.com",sep='')
        print("Mailbox password: ", passwd)
    else:
        raise RuntimeError('Отдел "{0}" не найден'.format(udep))

    payload = {
        'nickname': unik,
        'name': {'first': ufirst, 'last': ulast},
        'department_id': department_id,
        'password': passwd,
        'gender': sex,
    }
    headers = {
        'Authorization': 'OAuth ' + TOKEN,
        'User-Agent': USER_AGENT,
    }
    response = requests.post(
        'https://api.directory.yandex.net/v6/users/',
        json=payload,
        headers=headers,
        timeout=20,
    )
    # В случае ошибки, бросим исключение.
    response.raise_for_status()
    # А если всё хорошо, то вернём id.
    response_data = response.json()
    return response_data['id']

###############################

deps = load_already_created_deps()
users = load_already_created_users()
passwd = create_random_password(12)
create_user(ufirst, ulast, unik, udep, passwd, deps, users)


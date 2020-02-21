#!/bin/bash

echo "create database if not exists polr;" | mysql -u root
/usr/bin/supervisord
#!/bin/sh
cwd=`dirname "${0}"`
. $cwd/../auto_login.sh

# settings
host='your host name'
login_name='your account'
password='your password'

auto_login $host $login_name $password

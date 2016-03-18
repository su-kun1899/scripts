#!/bin/sh

auto_login() {
host=$1
login_name=$2
password=$3

expect -c "
set timeout 30
spawn ssh $login_name@$host
expect \"$login_name@$host's password:\" {
    send \"$password\n\"
}
interact
"
}

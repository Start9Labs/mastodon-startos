#!/bin/bash
set -e

password_unparsed=$(tootctl accounts modify --reset-password --role admin $(tootctl accounts get-first-username))
password=$(echo $password_unparsed | awk '{ print $NF }')
cat << EOF
{
    "version": "0",
    "message": "New password",
    "value": "$password",
    "copyable": false,
    "qr": false
}
EOF

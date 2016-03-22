#!/bin/bash

export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
grep -v ^wordpress /etc/passwd > "$HOME/passwd"
echo "wordpress:x:${USER_ID}:${GROUP_ID}:Wordpress user:${HOME}:/sbin/nologin" >> "$HOME/passwd"
export LD_PRELOAD=libnss_wrapper.so
export NSS_WRAPPER_PASSWD=${HOME}/passwd
export NSS_WRAPPER_GROUP=/etc/group
exec httpd -D FOREGROUND

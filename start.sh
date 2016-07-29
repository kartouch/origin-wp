#!/bin/bash


# Generate passwd file based on current uid

export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
grep -v ^wordpress /etc/passwd > "/tmp/passwd"
echo "wordpress:x:${USER_ID}:${GROUP_ID}:Wordpress user:${NGINX_HOME}:/bin/bash" >> "/tmp/passwd"
export LD_PRELOAD=libnss_wrapper.so
export NSS_WRAPPER_PASSWD=/tmp/passwd
export NSS_WRAPPER_GROUP=/etc/group

mv $NGINX_HOME/wp-config-sample.php $NGINX_HOME/wp-config.php && \
sed -i "s|database_name_here|$MYSQL_DATABASE|g" $NGINX_HOME/wp-config.php && \
sed -i "s|username_here|$MYSQL_USER|g" $NGINX_HOME/wp-config.php && \
sed -i "s|password_here|$MYSQL_PASSWORD|g" $NGINX_HOME/wp-config.php && \
sed -i "s|localhost|$MYSQL_SERVICE_HOST|g" $NGINX_HOME/wp-config.php && \
echo "define('FS_METHOD', 'direct');" >> $NGINX_HOME/wp-config.php


exec /usr/bin/supervisord -n -c /etc/supervisord.conf

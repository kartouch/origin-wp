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
sed -i "s|define('AUTH_KEY',         'put your unique phrase here');|define('AUTH_KEY',         '$(head -c1M /dev/urandom | sha1sum | cut -d' ' -f1)');|g" $NGINX_HOME/wp-config.php && \
sed -i "s|define('SECURE_AUTH_KEY',  'put your unique phrase here');|define('SECURE_AUTH_KEY',  '$(head -c1M /dev/urandom | sha1sum | cut -d' ' -f1)');|g" $NGINX_HOME/wp-config.php && \
sed -i "s|define('LOGGED_IN_KEY',    'put your unique phrase here');|define('LOGGED_IN_KEY',    '$(head -c1M /dev/urandom | sha1sum | cut -d' ' -f1)');|g" $NGINX_HOME/wp-config.php && \
sed -i "s|define('NONCE_KEY',        'put your unique phrase here');|define('NONCE_KEY',        '$(head -c1M /dev/urandom | sha1sum | cut -d' ' -f1)');|g" $NGINX_HOME/wp-config.php && \
sed -i "s|define('AUTH_SALT',        'put your unique phrase here');|define('AUTH_SALT',        '$(head -c1M /dev/urandom | sha1sum | cut -d' ' -f1)');|g" $NGINX_HOME/wp-config.php && \
sed -i "s|define('SECURE_AUTH_SALT', 'put your unique phrase here');|define('SECURE_AUTH_SALT', '$(head -c1M /dev/urandom | sha1sum | cut -d' ' -f1)');|g" $NGINX_HOME/wp-config.php && \
sed -i "s|define('LOGGED_IN_SALT',   'put your unique phrase here');|define('LOGGED_IN_SALT',   '$(head -c1M /dev/urandom | sha1sum | cut -d' ' -f1)');|g" $NGINX_HOME/wp-config.php && \
sed -i "s|define('NONCE_SALT',       'put your unique phrase here');|define('NONCE_SALT',       '$(head -c1M /dev/urandom | sha1sum | cut -d' ' -f1)');|g" $NGINX_HOME/wp-config.php && \
echo "define('FS_METHOD', 'direct');" >> $NGINX_HOME/wp-config.php && \
chmod 660 $NGINX_HOME/wp-config.php

exec /usr/bin/supervisord -n -c /etc/supervisord.conf

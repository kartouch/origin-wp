FROM centos:latest

ENV WP_HOME /wordpress

RUN yum install -y httpd php php-pecl-apcu php-cli php-pear php-pdo php-mysqlnd php-pecl-memcache php-pecl-memcached php-gd php-mbstring php-mcrypt php-xml wget tar nss_wrapper gettext && \
    rm -rf /var/cache/yum/* && \
    groupadd wordpress -g 55 && \
    useradd wordpress -u 55 -g wordpress -s /sbin/nologin -d "$WP_HOME" && \
    test "$(id wordpress)" = "uid=55(wordpress) gid=55(wordpress) groups=55(wordpress)"

RUN cd / && \
    wget -nv https://wordpress.org/latest.tar.gz && \
    tar xvfa latest.tar.gz && \
    mkdir -p $WP_HOME/{scripts.d,phpsessions} && \
    mv $WP_HOME/wp-config-sample.php $WP_HOME/wp-config.php && \
    sed -i 's|'\'database_name_here\''|getenv('MYSQL_DATABASE')|g' $WP_HOME/wp-config.php && \
    sed -i 's|'\'username_here\''|getenv('MYSQL_USER')|g' $WP_HOME/wp-config.php && \
    sed -i 's|'\'password_here\''|getenv('MYSQL_PASSWORD')|g' $WP_HOME/wp-config.php && \
    sed -i 's|'\'localhost\''|getenv('MYSQL_SERVICE_HOST')|g' $WP_HOME/wp-config.php 

COPY ./scripts.d/ $WP_HOME/scripts.d
RUN sed -i -f $WP_HOME/scripts.d/httpdconf.sed /etc/httpd/conf/httpd.conf && \
    chmod -R a+rwx /var/run/httpd && \
    cp $WP_HOME/scripts.d/wp.conf /etc/httpd/conf.d/welcome.conf && \
    chown -R wordpress.0 $WP_HOME && \
    chmod -R 770 $WP_HOME 

WORKDIR $WP_HOME

VOLUME ["/wordpress"]
EXPOSE 8080
USER 55
CMD ["./scripts.d/start.sh"]



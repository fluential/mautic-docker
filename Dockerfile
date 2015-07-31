# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:0.9.17

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# ...put your own build instructions here...

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get -y upgrade && apt-get -yq install \
        unzip \
        git \
        curl \
        apache2 \
        libapache2-mod-php5 \
        php5-intl \
        php5-mysql \
        php5-gd \
        php5-curl \
        php-pear \
        php5-mcrypt \
        php-apc && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    sed -i "s/variables_order.*/variables_order = \"EGPCS\"/g" /etc/php5/apache2/php.ini
RUN php5enmod mcrypt intl
RUN mkdir -p /etc/service/apache2
ADD run_apache2.sh /etc/service/apache2/run
ADD var_html.conf /etc/apache2/conf-available/var_html.conf
RUN a2enconf var_html
RUN chmod 755 /etc/service/apache2/run
RUN mv /var/www/html /var/www/html.old
RUN cd /var/www/ && curl -q -L https://github.com/mautic/mautic/archive/master.zip > master.zip && unzip master.zip && mv mautic-master html
VOLUME /var/www/html
VOLUME /etc/apache2
# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

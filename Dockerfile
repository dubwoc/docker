FROM debian:jessie
MAINTAINER dubwoc <scottz@clevar.me>
ENV DEBIAN_FRONTEND noninteractive
ENV LANG en_US.UTF-8
ENV LC_ALL C.UTF-8
ENV LANGUAGE en_US.UTF-8
RUN apt-get update && apt-get dist-upgrade -y
RUN groupadd -g 6001 nasdisk
RUN useradd --create-home -g 6001 -u 6000 nas
#--End Nas Preample--#
RUN apt-get install -y  apache2 \
                        wget \
                        php5 \
                        php5-json \
                        php5-curl \
                        php5-mysqlnd \
                        php5-gd \
                        pwgen \
                        lame \
                        libvorbis-dev \
                        vorbis-tools \
                        flac \
                        libmp3lame-dev \
                        libavcodec-extra* \
                        # libfaac-dev \
                        libtheora-dev \
                        libvpx-dev \
                        libav-tools \
                        git
    # setup apache with default ampache vhost
ADD 001-ampache.conf /etc/apache2/sites-available/
RUN rm -rf /etc/apache2/sites-enabled/*
RUN ln -s /etc/apache2/sites-available/001-ampache.conf /etc/apache2/sites-enabled/
RUN a2enmod rewrite
# Install composer for dependency management
RUN php -r "readfile('https://getcomposer.org/installer');" | php && \
    mv composer.phar /usr/local/bin/composer

# For local testing / faster builds
# COPY master.tar.gz /opt/master.tar.gz
# ADD https://github.com/ampache/ampache/archive/3.8.2.tar.gz /opt/3.8.2.tar.gz

ADD https://github.com/ampache/ampache/archive/master.tar.gz /opt/master.tar.gz
# extraction / installation
RUN rm /var/www/html/index.html && \
    tar -C /var/www/html -xf /opt/master.tar.gz --strip=1 && \
    cd /var/www/html && composer install --prefer-source --no-interaction && \
    chown -R www-data /var/www
RUN mkdir /var/log/ampache && chown www-data /var/log/ampache
ADD htaccess.channel /var/www/html/channel/.htaccess
ADD htaccess.rest /var/www/html/rest/.htaccess
ADD htaccess.play /var/www/html/play/.htaccess
# Do not know how this works right now.
# VOLUME ["/var/www/html/config"]
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

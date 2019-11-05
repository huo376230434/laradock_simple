#
#--------------------------------------------------------------------------
# Image Setup
#--------------------------------------------------------------------------
#

ARG PHP_VERSION=${PHP_VERSION}
FROM php:${PHP_VERSION}-alpine

LABEL maintainer="Mahmoud Zalt <mahmoud@zalt.me>"

ARG CHANGE_SOURCE=false
RUN if [ ${CHANGE_SOURCE} = true ]; then \
    # Change application source from dl-cdn.alpinelinux.org to aliyun source
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/' /etc/apk/repositories \
;fi


RUN apk --update add wget \
  curl \
  git \
  build-base \
  libmemcached-dev \
  libmcrypt-dev \
  libxml2-dev \
  pcre-dev \
  zlib-dev \
  #这三个是装GD库必须的
 freetype-dev \
 libjpeg-turbo-dev \
 libpng-dev \
  autoconf \
  cyrus-sasl-dev \
  libgsasl-dev \
  supervisor

RUN docker-php-ext-install gd mysqli mbstring pdo pdo_mysql tokenizer xml pcntl
#暂时不需要mongo 和memcached mcrypt这三个扩展，每次安装都很浪费时间，不装吧，以后有需要再说
#RUN pecl channel-update pecl.php.net && pecl install memcached mcrypt-1.0.1 mongodb && docker-php-ext-enable memcached mongodb


# Add a non-root user:
ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}

RUN addgroup -g ${PGID} laradock && \
    adduser -D -G laradock -u ${PUID} laradock

#Install SOAP package:
ARG INSTALL_SOAP=false
RUN if [ ${INSTALL_SOAP} = true ]; then \
    docker-php-ext-install soap \
;fi

#Install BCMath package:
ARG INSTALL_BCMATH=false
RUN if [ ${INSTALL_BCMATH} = true ]; then \
    docker-php-ext-install bcmath \
;fi

# Install PostgreSQL drivers:
ARG INSTALL_PGSQL=false
RUN if [ ${INSTALL_PGSQL} = true ]; then \
    apk --update add postgresql-dev \
        && docker-php-ext-install pdo_pgsql \
;fi

# Install ZipArchive:
ARG INSTALL_ZIP_ARCHIVE=false
RUN if [ ${INSTALL_ZIP_ARCHIVE} = true ]; then \
    apk --update add libzip-dev && \
    docker-php-ext-configure zip --with-libzip && \
    # Install the zip extension
    docker-php-ext-install zip \
;fi

# Install MySQL Client:
ARG INSTALL_MYSQL_CLIENT=false
RUN if [ ${INSTALL_MYSQL_CLIENT} = true ]; then \
    apk --update add mysql-client \
;fi

# Install FFMPEG:
ARG INSTALL_FFMPEG=false
RUN if [ ${INSTALL_FFMPEG} = true ]; then \
    apk --update add ffmpeg \
;fi

# Install AMQP:
ARG INSTALL_AMQP=false

RUN if [ ${INSTALL_AMQP} = true ]; then \
    apk --update add rabbitmq-c rabbitmq-c-dev && \
    pecl install amqp && \
    docker-php-ext-enable amqp && \
    docker-php-ext-install sockets \
;fi

# Install Gearman:
ARG INSTALL_GEARMAN=false

RUN if [ ${INSTALL_GEARMAN} = true ]; then \
    docker-php-ext-install gearman \
;fi

# Install Cassandra drivers:
ARG INSTALL_CASSANDRA=false
RUN if [ ${INSTALL_CASSANDRA} = true ]; then \
  apk --update add cassandra-cpp-driver \
  ;fi

WORKDIR /usr/src
RUN if [ ${INSTALL_CASSANDRA} = true ]; then \
  git clone https://github.com/datastax/php-driver.git \
  && cd php-driver/ext \
  && phpize \
  && mkdir -p /usr/src/php-driver/build \
  && cd /usr/src/php-driver/build \
  && ../ext/configure --with-php-config=/usr/bin/php-config7.1 > /dev/null \
  && make clean >/dev/null \
  && make >/dev/null 2>&1 \
  && make install \
  && docker-php-ext-enable cassandra \
;fi

# Install Phalcon ext
ARG INSTALL_PHALCON=false
ARG PHALCON_VERSION
ENV PHALCON_VERSION ${PHALCON_VERSION}

RUN if [ $INSTALL_PHALCON = true ]; then \
    apk --update add unzip gcc make re2c bash\
    && curl -L -o /tmp/cphalcon.zip https://github.com/phalcon/cphalcon/archive/v${PHALCON_VERSION}.zip \
    && unzip -d /tmp/ /tmp/cphalcon.zip \
    && cd /tmp/cphalcon-${PHALCON_VERSION}/build \
    && ./install \
    && rm -rf /tmp/cphalcon* \
;fi

RUN if [ $INSTALL_GHOSTSCRIPT = true ]; then \
    apk --update add ghostscript \
;fi

#Install GMP package:
ARG INSTALL_GMP=false
RUN if [ ${INSTALL_GMP} = true ]; then \
   apk add --update --no-cache gmp gmp-dev \
   && docker-php-ext-install gmp \
;fi

# Install Redis package:
ARG INSTALL_REDIS=false
RUN if [ ${INSTALL_REDIS} = true ]; then \
    # Install Redis Extension
    printf "\n" | pecl install -o -f redis \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis \
;fi

###########################################################################
# Swoole EXTENSION
###########################################################################

ARG INSTALL_SWOOLE=false

RUN if [ ${INSTALL_SWOOLE} = true ]; then \
    # Install Php Swoole Extension
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
      pecl -q install swoole-2.0.10; \
    else \
      if [ $(php -r "echo PHP_MINOR_VERSION;") = "0" ]; then \
        pecl install swoole-2.2.0; \
      else \
        pecl install swoole; \
      fi \
    fi \
    && docker-php-ext-enable swoole \
;fi

###########################################################################
# Taint EXTENSION
###########################################################################

ARG INSTALL_TAINT=false

RUN if [ ${INSTALL_TAINT} = true ]; then \
    # Install Php TAINT Extension
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "7" ]; then \
      pecl install taint; \
    fi && \
    docker-php-ext-enable taint \
;fi

#
#--------------------------------------------------------------------------
# Optional Software's Installation
#--------------------------------------------------------------------------
#
# If you need to modify this image, feel free to do it right here.
#
    # -- Your awesome modifications go here -- #

#
#--------------------------------------------------------------------------
# Check PHP version
#--------------------------------------------------------------------------
#

RUN php -v | head -n 1 | grep -q "PHP ${PHP_VERSION}."




###########################################################################
# Composer:
###########################################################################

USER root



# Install composer and add its bin to the PATH.
RUN curl -sS https://getcomposer.org/installer | php
RUN    echo "export PATH=${PATH}:/var/www/vendor/bin" >> ~/.bashrc
RUN   mv composer.phar /usr/local/bin/composer

# Source the bash
RUN . ~/.bashrc

# Add the composer.json
COPY ./composer.json /root/.composer/composer.json

# Add the auth.json for magento 2 credentials
COPY ./auth.json /root/.composer/auth.json


# Export composer vendor path
RUN echo "" >> ~/.bashrc && \
    echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> ~/.bashrc


# Check if global install need to be ran
ARG COMPOSER_GLOBAL_INSTALL=false
ENV COMPOSER_GLOBAL_INSTALL ${COMPOSER_GLOBAL_INSTALL}

RUN if [ ${COMPOSER_GLOBAL_INSTALL} = true ]; then \
    # run the install
    composer global install \
;fi

# Check if auth file is disabled
ARG COMPOSER_AUTH=false
ENV COMPOSER_AUTH ${COMPOSER_AUTH}

RUN if [ ${COMPOSER_AUTH} = false ]; then \
    # remove the file
    rm /root/.composer/auth.json \
;fi

ARG COMPOSER_REPO_PACKAGIST
ENV COMPOSER_REPO_PACKAGIST ${COMPOSER_REPO_PACKAGIST}

RUN if [ ${COMPOSER_REPO_PACKAGIST} ]; then \
    composer config -g repo.packagist composer ${COMPOSER_REPO_PACKAGIST} \
;fi

# Export composer vendor path
RUN echo "" >> ~/.bashrc && \
    echo 'export PATH="~/.composer/vendor/bin:$PATH"' >> ~/.bashrc


# Clean up
RUN rm /var/cache/apk/* \
    && mkdir -p /var/www

WORKDIR /etc/supervisor/conf.d/


#CMD php -r '$path="/var/www";var_dump($path); $handler = opendir($path);  $arr = []; while( ($filename = readdir($handler)) !== false ) { if($filename != "." && $filename != ".."){  $temp_path = $path . "/" . $filename;  if ( is_dir($temp_path) ) {  array_push($arr, $temp_path); }  } }           closedir($handler);            print_r($arr);file_put_content("haha","/var/www/haha");'

#CMD php -r '$path="/var/www";var_dump($path); $handler = opendir($path);  $arr = []; \
#
#while( ($filename = readdir($handler)) !== false ) { if($filename != "." && $filename != ".."){  $temp_path = $path . "/" . $filename;  if ( is_dir($temp_path) ) {  array_push($arr, $temp_path); }  } }           closedir($handler);            print_r($arr);file_put_contents("haha","/var/www/haha");' && crond && /usr/bin/supervisord -n -c /etc/supervisord.conf;
#



#
#--------------------------------------------------------------------------
# Optional Supervisord Configuration
#--------------------------------------------------------------------------
#
# Modify the ./supervisor.conf file to match your App's requirements.
# Make sure you rebuild your container with every change.
#

COPY supervisord.conf /etc/supervisord.conf




CMD php -r '$path="/var/www";var_dump($path); $handler = opendir($path); $arr = [];$crontab_path = "/etc/crontabs/root";\
            while( ($filename = readdir($handler)) !== false ) {\
                if($filename != "." && $filename != ".." && is_dir($path . "/" . $filename) && file_exists($path . "/" . $filename."/artisan")){\
                    $command_str = "* * * * *  php /var/www/$filename/artisan schedule:run >> /dev/null 2>&1".PHP_EOL;\
                    if (!strstr(file_get_contents($crontab_path), $command_str)) file_put_contents($crontab_path, $command_str, FILE_APPEND);\
                } }' && crond && /usr/bin/supervisord -n -c /etc/supervisord.conf;
#COPY ./../crontab /var/spool/cron/crontabs/root


#CMD ["/usr/bin/supervisord", "-n", "-c",  "/etc/supervisord.conf"]

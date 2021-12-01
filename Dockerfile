FROM ubuntu:focal

ARG PHP_VERSION
ENV INSTALLED_PHP_VERSION=$PHP_VERSION

RUN cp /bin/bash /bin/sh
RUN set -e; \
    # Ensure apt is up-to-date and install Sury repo \
    apt update; \
    apt install -y software-properties-common curl; \
    add-apt-repository -y ppa:ondrej/php; \
    # Packages common to all PHP versions \
    PACKAGES=( \
        "php${PHP_VERSION}-bz2" \
        "php${PHP_VERSION}-cli" \
        "php${PHP_VERSION}-curl" \
        "php${PHP_VERSION}-dev" \
        "php${PHP_VERSION}-fileinfo" \
        "php${PHP_VERSION}-intl" \
        "php${PHP_VERSION}-mbstring" \
        "php${PHP_VERSION}-phar" \
        "php${PHP_VERSION}-phpdbg" \
        "php${PHP_VERSION}-readline" \
        "php${PHP_VERSION}-sockets" \
        "php${PHP_VERSION}-xml" \
        "php${PHP_VERSION}-xsl" \
        "php${PHP_VERSION}-zip" \
    ); \
    # Additional packages for PHP 7 versions \
    if [[ "${PHP_VERSION:0:1}" -eq "7" ]];then \
        PACKAGES+=("php${PHP_VERSION}-json"); \
    fi; \
    # Install PHP packages and build tools \
    apt install -y \
        git \
        libxml2-utils \
        libzip-dev \
        wget \
        zip \
        ${PACKAGES[*]}; \
    # Set PHP version and its dev tools as defaults \
    update-alternatives --set php /usr/bin/php${PHP_VERSION}; \
    update-alternatives --set phpize /usr/bin/phpize${PHP_VERSION}; \
    update-alternatives --set php-config /usr/bin/php-config${PHP_VERSION}

COPY build-extension.sh /usr/bin/build-extension

ENTRYPOINT ["/usr/bin/build-extension"]

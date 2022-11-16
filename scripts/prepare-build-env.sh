#!/bin/bash

set -e

# Ensure apt is up-to-date and install Sury repo
apt update
apt install -y software-properties-common curl
add-apt-repository -y ppa:ondrej/php

# Packages common to all PHP versions
PACKAGES=(
    "php${INSTALLED_PHP_VERSION}-bz2"
    "php${INSTALLED_PHP_VERSION}-cli"
    "php${INSTALLED_PHP_VERSION}-curl"
    "php${INSTALLED_PHP_VERSION}-dev"
    "php${INSTALLED_PHP_VERSION}-fileinfo"
    "php${INSTALLED_PHP_VERSION}-intl"
    "php${INSTALLED_PHP_VERSION}-mbstring"
    "php${INSTALLED_PHP_VERSION}-phar"
    "php${INSTALLED_PHP_VERSION}-phpdbg"
    "php${INSTALLED_PHP_VERSION}-readline"
    "php${INSTALLED_PHP_VERSION}-sockets"
    "php${INSTALLED_PHP_VERSION}-xml"
    "php${INSTALLED_PHP_VERSION}-xsl"
    "php${INSTALLED_PHP_VERSION}-zip"
)

# Additional packages for PHP 7 versions
if [[ "${INSTALLED_PHP_VERSION:0:1}" -eq "7" ]];then
    PACKAGES+=("php${INSTALLED_PHP_VERSION}-json")
fi

# Install PHP packages and build tools
apt install -y \
    git \
    libxml2-utils \
    libzip-dev \
    wget \
    zip \
    "${PACKAGES[@]}"

# Set PHP version and its dev tools as defaults
update-alternatives --set php "/usr/bin/php${INSTALLED_PHP_VERSION}"
update-alternatives --set phpize "/usr/bin/phpize${INSTALLED_PHP_VERSION}"
update-alternatives --set php-config "/usr/bin/php-config${INSTALLED_PHP_VERSION}"

#!/bin/bash

set -e

function usage() {
    echo "Usage:"
    echo "  build-extension <swoole|openswoole> <version>"
}

if [[ $# -ne 2 ]];then
    echo "Received $# arguments:"
    echo "$@"
    echo ""
    usage
    exit 1
fi

EXTENSION=$1
VERSION=$2

cd /tmp

# Fetch and extract the archive
echo "Fetching ${EXTENSION} ${VERSION} source code"
curl -L -o "swoole-src-${VERSION}.tgz" "https://github.com/${EXTENSION}/swoole-src/archive/refs/tags/v${VERSION}.tar.gz"
tar xzf "swoole-src-${VERSION}.tgz"
cd "swoole-src-${VERSION}"

# Build the extension
echo "Preparing to build"
phpize
./configure --enable-swoole --enable-sockets
echo "Building"
make
echo "Installing"
make install

# Copy the artifacts to the shared volume
echo "Copying artifacts"
EXTENSION_DIR=$(php-config --extension-dir)
INCLUDE_DIR=$(php-config --include-dir)
mkdir -p "/artifacts/etc/php/${INSTALLED_PHP_VERSION}/mods-available"
mkdir -p "/artifacts/${EXTENSION_DIR}"
mkdir -p "/artifacts/${INCLUDE_DIR}/ext"
echo "; configuration for php ${EXTENSION} module
; priority=60
extension=${EXTENSION}.so" > "/artifacts/etc/php/${INSTALLED_PHP_VERSION}/mods-available/${EXTENSION}.ini"
cp "${EXTENSION_DIR}/${EXTENSION}.so" "/artifacts${EXTENSION_DIR}/"
cp -a "${INCLUDE_DIR}/ext/${EXTENSION}" "/artifacts${INCLUDE_DIR}/ext/"
echo "DONE!"

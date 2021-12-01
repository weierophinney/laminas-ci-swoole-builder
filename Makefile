#!make
########################## Variables #####################
HERE := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
##########################################################

PHP_VERSION := 7.4
SWOOLE_VERSION := 4.8.2
OPEN_SWOOLE_VERSION := 4.8.0
S3_BUCKET := uploads.mwop.net
S3_SUBDIR := laminas-ci
PACKAGE_FILE := swoole-$(SWOOLE_VERSION)-openswoole-$(OPEN_SWOOLE_VERSION).tgz

.PHONY:

date := $(shell date +%Y-%m-%d)

default: help

##@ Help

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[0-9a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-40s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Create the containers for building the extensions

container:  ## Build a single PHP container based on PHP_VERSION
	@printf "\n\033[92mBuilding container for PHP version $(PHP_VERSION)...\033[0m\n"
	docker build -t laminas/laminas-ext-builder:$(PHP_VERSION) --build-arg PHP_VERSION=$(PHP_VERSION) .
	@printf "\n\033[92mBuilt image laminas/laminas-ext-builder:$(PHP_VERSION)\033[0m\n"

containers:  ## Create all PHP containers for building extensions
	@printf "\n\033[92mBuilding all containers ...\033[0m\n"
	for VERSION in 7.3 7.4 8.0 8.1;do \
		printf "\n\033[92mBuilding container for PHP $$VERSION ...\033[0m\n" \
		docker build -t laminas/laminas-ext-builder:$$VERSION --build-arg PHP_VERSION=$$VERSION . \
		printf "\n\033[92mBuilt container for PHP $$VERSION\033[0m\n" \
	done
	@printf "\n\033[92mBuilt all containers\033[0m\n"

##@ Build extensions

swoole:  ## Build Swoole version SWOOLE_VERSION using PHP_VERSION container image
	@printf "\n\033[92mBuilding Swoole $(SWOOLE_VERSION) for PHP version $(PHP_VERSION)...\033[0m\n"
	docker run -v $(shell realpath .)/artifacts:/artifacts laminas/laminas-ext-builder:$(PHP_VERSION) swoole $(SWOOLE_VERSION)
	@printf "\n\033[92mBuilt Swoole $(SWOOLE_VERSION) for PHP version $(PHP_VERSION)\033[0m\n"

openswoole:  ## Build OpenSwoole version OPEN_SWOOLE_VERSION using PHP_VERSION container image
	@printf "\n\033[92mBuilding OpenSwoole $(OPEN_SWOOLE_VERSION) for PHP version $(PHP_VERSION)...\033[0m\n"
	docker run -v $(shell realpath .)/artifacts:/artifacts laminas/laminas-ext-builder:$(PHP_VERSION) openswoole $(OPEN_SWOOLE_VERSION)
	@printf "\n\033[92mBuilt OpenSwoole $(OPEN_SWOOLE_VERSION) for PHP version $(PHP_VERSION)\033[0m\n"

allswoole:  ## Build both swoole and openswoole for a given PHP_VERSION
	@printf "\n\033[92mBuilding Swoole $(SWOOLE_VERSION) for PHP version $(PHP_VERSION)...\033[0m\n"
	docker run -v $(shell realpath .)/artifacts:/artifacts laminas/laminas-ext-builder:$(PHP_VERSION) swoole $(SWOOLE_VERSION)
	@printf "\n\033[92mBuilt Swoole $(SWOOLE_VERSION) for PHP version $(PHP_VERSION)\033[0m\n"
	@printf "\n\033[92mBuilding OpenSwoole $(OPEN_SWOOLE_VERSION) for PHP version $(PHP_VERSION)...\033[0m\n"
	docker run -v $(shell realpath .)/artifacts:/artifacts laminas/laminas-ext-builder:$(PHP_VERSION) openswoole $(OPEN_SWOOLE_VERSION)
	@printf "\n\033[92mBuilt OpenSwoole $(OPEN_SWOOLE_VERSION) for PHP version $(PHP_VERSION)\033[0m\n"

allswooleallphp:  ## Build both swoole and openswoole for all supported PHP versions
	for VERSION in 7.3 7.4 8.0 8.1;do \
		printf "\n\033[92mBuilding Swoole $(SWOOLE_VERSION) for PHP version $$VERSION...\033[0m\n" \
		docker run -v $(shell realpath .)/artifacts:/artifacts laminas/laminas-ext-builder:$$VERSION swoole $(SWOOLE_VERSION) \
		printf "\n\033[92mBuilt Swoole $(SWOOLE_VERSION) for PHP version $$VERSION\033[0m\n" \
		printf "\n\033[92mBuilding OpenSwoole $(OPEN_SWOOLE_VERSION) for PHP version $$VERSION...\033[0m\n" \
		docker run -v $(shell realpath .)/artifacts:/artifacts laminas/laminas-ext-builder:$$VERSION openswoole $(OPEN_SWOOLE_VERSION) \
		printf "\n\033[92mBuilt OpenSwoole $(OPEN_SWOOLE_VERSION) for PHP version $$VERSION\033[0m\n" \
	done

##@ Packaging and upload

package:  ## Package the artifacts
	@printf "\n\033[92mPackaging artifacts...\033[0m\n"
	cd artifacts && tar czf ../swoole-$(SWOOLE_VERSION)-openswoole-$(OPEN_SWOOLE_VERSION).tgz . -vv
	@printf "\n\033[92mDone packaging artifacts\033[0m\n"

upload: $(PACKAGE_FILE)  ## Upload the artifacts
	@printf "\n\033[92mUploading artifacts...\033[0m\n"
	aws s3 cp $(PACKAGE_FILE) s3://$(S3_BUCKET)/$(S3_SUBDIR)/$(PACKAGE_FILE)
	@printf "\n\033[92mUploaded artifacts\033[0m\n"

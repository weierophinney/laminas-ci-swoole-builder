#!make
########################## Variables #####################
HERE := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
##########################################################

PHP_VERSION := 7.4
SWOOLE_VERSION := 4.8.12
OPEN_SWOOLE_VERSION := 4.12.0

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
	for VERSION in 7.3 7.4 8.0 8.1 8.2 8.3;do \
		printf "\n\033[92mBuilding container for PHP $$VERSION ...\033[0m\n" ; \
		docker build -t laminas/laminas-ext-builder:$$VERSION --build-arg PHP_VERSION=$$VERSION . ; \
		printf "\n\033[92mBuilt container for PHP $$VERSION\033[0m\n" ; \
	done
	@printf "\n\033[92mBuilt all containers\033[0m\n"

##@ Build extensions

swoole: clean-artifacts  ## Build Swoole version SWOOLE_VERSION using PHP_VERSION container image
	@printf "\n\033[92mBuilding Swoole $(SWOOLE_VERSION) for PHP version $(PHP_VERSION)...\033[0m\n"
	docker run -v $(shell realpath .)/artifacts:/artifacts laminas/laminas-ext-builder:$(PHP_VERSION) swoole $(SWOOLE_VERSION)
	@printf "\n\033[92mPackaging Swoole $(SWOOLE_VERSION) for PHP version $(PHP_VERSION)...\033[0m\n"
	cd artifacts && tar czf ../php$(PHP_VERSION)-swoole.tgz . -vv
	@printf "\n\033[92mBuilt and packaged Swoole $(SWOOLE_VERSION) for PHP version $(PHP_VERSION)\033[0m\n"

openswoole: clean-artifacts  ## Build OpenSwoole version OPEN_SWOOLE_VERSION using PHP_VERSION container image
	@printf "\n\033[92mBuilding OpenSwoole $(OPEN_SWOOLE_VERSION) for PHP version $(PHP_VERSION)...\033[0m\n"
	docker run -v $(shell realpath .)/artifacts:/artifacts laminas/laminas-ext-builder:$(PHP_VERSION) openswoole $(OPEN_SWOOLE_VERSION)
	@printf "\n\033[92mPackaging OpenSwoole $(OPEN_SWOOLE_VERSION) for PHP version $(PHP_VERSION)...\033[0m\n"
	cd artifacts && tar czf ../php$(PHP_VERSION)-openswoole.tgz . -vv
	@printf "\n\033[92mBuilt and packaged OpenSwoole $(OPEN_SWOOLE_VERSION) for PHP version $(PHP_VERSION)\033[0m\n"

all:  ## Build and package both Swoole and OpenSwoole for all supported PHP versions
	for VERSION in 7.3 7.4 8.0 8.1 8.2 8.3;do \
		cd $(HERE) ; \
		make swoole PHP_VERSION=$$VERSION ; \
		cd $(HERE) ; \
		make openswoole PHP_VERSION=$$VERSION ; \
	done

##@ Cleanup

clean-artifacts:  ## Cleanup artifacts directory
	@printf "\n\033[92mCleaning up artifacts...\033[0m\n"
	cd $(HERE)/artifacts && sudo rm -rf ./*

clean-packages:  ## Cleanup (remove) previously built packages
	@printf "\n\033[92mCleaning up artifacts...\033[0m\n"
	cd $(HERE) && rm -rf *.tgz

clean: clean-artifacts clean-packages ## Cleanup (remove) all artifacts and packages

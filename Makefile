.PHONY: help images test

.DEFAULT_GOAL:=help

include .env
include modules/.env

CENTOS_VERSION ?= 7.5.1804
VARNISH_VERSION ?= 6.0.1-1
IMAGE_OWNER ?= mondiamedia
MODULE ?= 

images: ## Builds docker images (base, varnish-devel, varnish) for given env variable VARNISH_VERSION.
	@echo "Building images..."
	./build_images.sh

rpms: images ## Builds Varnish and modules RPMs for given env variable VARNISH_VERSION.
	@echo "Building VMODS RPMs..."
	./modules/build_vmods.sh

test: ## Tests Varnish and modules RPMs in a simple Docker Compose setup.
	@echo "Starting Varnish test environment..."
	./test.sh

clean-rpms: ## Cleans up the RPM distribution directory.
	@echo "Purging VMODS RPMs..."
	rm -rf ./modules/dist

clean-test: ## Cleans up the Docker Compose test environment.
	@echo "Purging Docker Compose setup..."
	docker-compose down --rmi local

help: ## Prints the help about targets.
	@printf "Usage:             make [\033[34mtarget\033[0m]\n"
	@printf "Default:           \033[34m%s\033[0m\n" $(.DEFAULT_GOAL)
	@printf "Targets:\n"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf " \033[34m%-17s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

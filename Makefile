.PHONY: help images test benchmark

.DEFAULT_GOAL:=help

include .env
include modules/.env

CENTOS_VERSION ?= 7.5.1804
VARNISH_VERSION ?= 6.0.1-1
IMAGE_OWNER ?= mondiamedia
MODULE ?= 
FORCE ?=

images: ## Builds docker images (base, varnish-devel, varnish) for given env variable VARNISH_VERSION.
	@echo "Building images..."
	./build_images.sh

rpms: images ## Builds Varnish and modules RPMs for given env variable VARNISH_VERSION.
	@echo "Building VMODS RPMs..."
	./modules/build_vmods.sh

start: rpms ## Starts Varnish with modules RPMs in a simple Docker Compose stack together with some backend service.
	@echo "Starting Varnish test environment..."
	@./compose.sh "up -d"

stop: ## Stops the test stack without removing the images
	@echo "Stopping Varnish test environment..."
	@./compose.sh down

clean: ## Cleans up the Docker Compose test environment.
	@echo "Purging Docker Compose setup..."
	@./compose.sh "down --rmi local"

varnishlog: ## Opens the varnishlog console
	@echo "Starting varnishlog..."
	@./compose.sh "exec varnish varnishlog"

clean-rpms: ## Cleans up the RPM distribution directory.
	@echo "Purging VMODS RPMs..."
	rm -rf ./modules/dist

load: ## Performs a load test for Varnish.
	@echo "Running load test..."
	./benchmark.sh

benchmark: clean start load clean ## Ensures stack whether it is started, performs benchmark and cleans up the stack after.
	@echo "Running benchmark..."

logs: ## Open docker compose log.
	@echo "Running load test..."
	@./compose.sh "logs -f" 

help: ## Prints the help about targets.
	@printf "Usage:             make [\033[34mtarget\033[0m]\n"
	@printf "Default:           \033[34m%s\033[0m\n" $(.DEFAULT_GOAL)
	@printf "Targets:\n"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf " \033[34m%-17s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

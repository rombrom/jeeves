# Variables
CONTAINER_NAME ?= jeeves
IMAGE_NAME     ?= jeeves
TAG            ?= latest
CONTAINER      ?= container
WORKDIR        ?= /mnt/workdir

-include .env

# Default target
.DEFAULT_GOAL := help

build: ## Build the docker image
	$(CONTAINER) build --build-arg WORKDIR=$(WORKDIR) -t $(IMAGE_NAME):$(TAG) .

run: stop ## Start the container (exit any existing before running)
	$(CONTAINER) run \
		--cpus 2 \
		--detach \
		--env-file .env \
		--ssh \
		--name $(CONTAINER_NAME) \
		--memory 2GB \
		--volume $(CURDIR)/config:/opt/config:ro \
		--volume $(WORKDIR):$(WORKDIR) \
		--volume jeeves-pi:/root/.pi \
		--volume jeeves-claude:/root/.claude \
		$(IMAGE_NAME):$(TAG)

start: ## Start the container if it exists
	$(CONTAINER) start $(CONTAINER_NAME)

stop: ## Stop and remove the running container
	-$(CONTAINER) stop $(CONTAINER_NAME)

kill: stop ## Stop and delete the container
	$(CONTAINER) delete $(CONTAINER_NAME)

sync: ## Synchronize jeeves filesystem with container
	$(CONTAINER) exec $(CONTAINER_NAME) /entrypoint.sh

clean: stop ## Remove the docker image
	$(CONTAINER) image delete $(IMAGE_NAME):$(TAG)

help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

.PHONY: build run start stop kill clean help sync

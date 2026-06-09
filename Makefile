# Variables
CONTAINER_NAME ?= jeeves
JEEVES_HOME    ?= /home/jeeves
IMAGE_NAME     ?= jeeves
TAG            ?= latest
WORKDIR        ?= /home/jeeves/code
WORKDIR_HOST   ?= $(WORKDIR)
CONTAINER      ?= container

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
		--name $(CONTAINER_NAME) \
		--memory 2GB \
		--rm \
		--ssh \
		--volume jeeves-claude:$(JEEVES_HOME)/.claude \
		--volume jeeves-pi:$(JEEVES_HOME)/.pi \
		--volume $(CURDIR)/config:/config:ro \
		--volume $(WORKDIR_HOST):$(WORKDIR) \
		$(IMAGE_NAME):$(TAG)

stop: ## Stop and remove the running container
	-$(CONTAINER) stop $(CONTAINER_NAME)

sync: ## Synchronize jeeves filesystem in JEEVESDIR with container
	$(CONTAINER) exec $(CONTAINER_NAME) /entrypoint.sh
	$(CONTAINER) exec $(CONTAINER_NAME) cp -R $(JEEVESDIR)/container/* /
	$(CONTAINER) exec $(CONTAINER_NAME) bash -c "find $(JEEVES_HOME)/.pi -iname package.json ! -path '*/node_modules/*' -execdir npm install \;"

clean: stop ## Remove the docker image
	$(CONTAINER) image delete $(IMAGE_NAME):$(TAG)

help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

.PHONY: build run stop clean help sync


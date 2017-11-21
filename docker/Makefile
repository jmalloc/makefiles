################################################################################
# Makefile for Docker
################################################################################
SHELL := /bin/bash -o pipefail

# Pre-requisites for building the Docker image. This would typically include
# anything you want to COPY or ADD to the image.
DOCKER_REQ ?=

# The Docker image tag to build (and optionally publish).
# This defaults to "dev" which is the tag used for local testing.
# Never push the "dev" tag to the registry.
DOCKER_TAG ?= dev

ifndef DOCKER_REPO
$(error "DOCKER_REPO must be defined in the project's Makefile.")
endif

# Arguments to pass to the "docker build" comand.
DOCKER_BUILD_ARGS ?=

################################################################################
# Commands (Phony Targets)
################################################################################

.PHONY: docker
docker: artifacts/logs/docker/$(DOCKER_TAG)

.PHONY: docker-push
docker-push: docker | $(DOCKER_PUSH_ERR)
ifeq ($(DOCKER_TAG),dev)
	$(error "Don't push the :dev tag to the registry!")
else
	docker push $(DOCKER_REPO):$(DOCKER_TAG)
endif

.PHONY: docker-clean
docker-clean::
	rm -f artifacts/logs/docker/$(DOCKER_TAG)
	-docker image rm $(DOCKER_REPO):$(DOCKER_TAG)

.PHONY: clean-all
clean-all:: docker-clean

.PHONY:
usage::
	@cat artifacts/make/docker/usage.txt
	@echo

################################################################################
# File Targets
################################################################################

.DELETE_ON_ERROR:

.SECONDARY: $(DOCKER_REQ)
artifacts/logs/docker/%: Dockerfile $(DOCKER_REQ)
	@mkdir -p "$(@D)"
	docker build $(DOCKER_BUILD_ARGS) -t $(DOCKER_REPO):$* . | tee "$@"

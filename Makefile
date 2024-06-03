SHELL := /bin/bash
SOURCES := $(wildcard *.py) $(wildcard scripts/**/*) $(wildcard blutter/**/*)
BUILD_DIR := dist
GIT_ARCHIVE := blutter.tar.gz
DOCKER_IMAGE_REF := docker_image_sha1_commit.txt

DOCKER ?= docker

all: $(BUILD_DIR)/$(DOCKER_IMAGE_REF)

$(BUILD_DIR)/$(GIT_ARCHIVE): $(SOURCES)
	@mkdir -p $(BUILD_DIR)
	git archive HEAD -o "$@"

$(BUILD_DIR)/$(DOCKER_IMAGE_REF): Dockerfile $(BUILD_DIR)/$(GIT_ARCHIVE)
	@#$(DOCKER) rmi blutter 2> /dev/null || true
	$(DOCKER) build --build-arg UID=$$(id -u) --build-arg GID=$$(id -g) -t blutter .
	git rev-parse HEAD > "$@"

.PHONY: clean down fresh image-base image-vesc-1036 import up

clean: down
	sudo chown -R "$(USER):$(USER)" .
	rm -rf $(CURDIR)/mnesia/*/rabbit*

down:
	docker compose down

fresh: down clean up import

VERSION ?= 3-management

image-base:
	docker build --pull --tag rabbitmq-base:latest --build-arg VERSION=$(VERSION) --file $(CURDIR)/docker/base .

image-vesc-1036:
	docker build --tag vesc-1036:latest --file $(CURDIR)/docker/vesc-1036 .

import:
	/bin/sh $(CURDIR)/import-defs.sh

up:
	docker compose up --detach

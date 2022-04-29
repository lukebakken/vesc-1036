.PHONY: clean down fresh image-base import up

clean: down
	sudo chown -R "$(USER):$(USER)" .
	rm -vrf $(CURDIR)/mnesia/*/rabbit*
	docker system prune --force
	docker image rm vesc-1036:latest
	docker image rm rabbitmq-base:latest

down:
	docker compose down

fresh: down clean up import

image-base:
	docker build --pull --tag rabbitmq-base:latest --file $(CURDIR)/docker/base .

image-base-3.8:
	docker build --pull --tag rabbitmq-base:latest --file $(CURDIR)/docker/base-3.8 .

image-vesc-1036:
	docker build --tag vesc-1036:latest --file $(CURDIR)/docker/vesc-1036 .

import:
	/bin/sh $(CURDIR)/import-defs.sh

up:
	docker compose up --detach

.PHONY: clean down fresh image-base import up

clean: down
	docker system prune --force

down:
	docker compose down

fresh: down clean up import

image-base:
	docker build --pull --tag rabbitmq-base:latest --file $(CURDIR)/docker/base .

image-vesc-1036:
	docker build --tag vesc-1036:latest --file $(CURDIR)/docker/vesc-1036 .

import:
	/bin/sh $(CURDIR)/import-defs.sh

up:
	docker compose up --detach

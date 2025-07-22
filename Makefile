include Makefile.env

ct ?= 

# Helper to conditionally add container argument
CONTAINER_ARG = $(if $(ct),$(ct),)

VARS_TO_PRINT = ct DEFAULT_MASTER SEATUNNEL_VER

define print_vars
	@echo "Makefile variables:"
	$(foreach var,$(VARS_TO_PRINT),\
		echo "  $(var) = $($(var))\n"\
	)
endef



network.create:
	docker network create --driver bridge --subnet 172.199.0.0/24 --gateway 172.199.0.1 integration || true

build:
	docker build -t quay.io/larryloi/seatunnel-$(SEATUNNEL_VER)-kas:latest -f ./Dockerfile-seatunnel-kas .

volume.rm.all:
	docker volume rm $$(docker volume ls -qf dangling=true)

volume.list:
	docker volume ls


ps:
	$(print_vars)
	docker compose ps -a

up:
	$(print_vars)
	docker compose up -d $(CONTAINER_ARG)

stop:
	docker compose stop $(CONTAINER_ARG)

down:
	docker compose down $(CONTAINER_ARG)

logs:
	docker compose logs -f $(CONTAINER_ARG)

shell:
	docker compose exec $(CONTAINER_ARG) bash

run:
	docker run \
		--rm \
		--name seatunnel-$(CONTAINER_ARG)-running \
		--network integration \
		-v ./seatunnel-web/application.yml:/opt/app/seatunnel-web/conf/application.yml \
		-v ./seatunnel-web/logs:/opt/app/seatunnel-web/logs \
		-v ./seatunnel-web/hazelcast-client.yaml:/opt/app/seatunnel-web/conf/hazelcast-client.yaml \
		-v ./seatunnel-web/plugin-mapping.properties:/opt/app/seatunnel-web/conf/plugin-mapping.properties \
		-ti $(image) /bin/sh

job.list:
	docker compose exec master /opt/seatunnel/bin/seatunnel.sh --list | grep -v INFO

job.run:
	docker compose exec master bash -c "bash /opt/seatunnel/job_run.sh $(name) "

job.cancel:
	docker compose exec master bash -c "/opt/seatunnel/bin/seatunnel.sh --cancel-job $(name)"

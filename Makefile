DEFAULT_MASTER = master1
SEATUNNEL_VER = 2.3.10

network.create:
	docker network create --driver bridge --subnet 172.199.0.0/24 --gateway 172.199.0.1 integration || true

build:
	docker build -t quay.io/larryloi/seatunnel-$(SEATUNNEL_VER)-kas:latest -f ./Dockerfile-seatunnel-kas .

volume.rm.all:
	docker volume rm $$(docker volume ls -qf dangling=true)

volume.list:
	docker volume ls


ps:
	docker compose ps

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f

master.shell:
	docker compose exec $(DEFAULT_MASTER) bash


worker1.shell:
	docker compose exec worker1 bash

worker2.shell:
	docker compose exec worker2 bash

job.list:
	docker compose exec master /opt/seatunnel/bin/seatunnel.sh --list | grep -v INFO

job.run:
	docker compose exec master bash -c "bash /opt/seatunnel/job_run.sh $(name) "

job.cancel:
	docker compose exec master bash -c "/opt/seatunnel/bin/seatunnel.sh --cancel-job $(name)"

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
	docker build -t seatunnel-$(SEATUNNEL_VER)-kas:latest -f ./Dockerfile-seatunnel-kas .

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



# job.list:
# 	docker compose exec master /opt/seatunnel/bin/seatunnel.sh --list | grep -v INFO
# 
# job.run:
# 	docker compose exec master bash -c "bash /opt/seatunnel/job_run.sh $(name) "
# 
# job.cancel:
# 	docker compose exec master bash -c "/opt/seatunnel/bin/seatunnel.sh --cancel-job $(name)"

system.info:
	@echo "System information:"
	curl ${CA_CERT} ${CURL_USER} -X GET ${CURL_USER} ${baseUrl}/system-monitoring-information | jq '.'

job.list:
	@echo "Running jobs:"
	curl ${CA_CERT} ${CURL_USER} -X GET ${CURL_USER} ${baseUrl}/running-jobs | jq -r '["JOB ID", "JOB NAME", "STATUS"], (.[] | [.jobId, .jobName, .jobStatus]) | @tsv ' | column -s : -t| sed 's/\"//g'

job.stop:
	@echo "Stopping job:"
	curl ${CA_CERT} ${CURL_USER} -X POST ${CURL_USER} "${baseUrl}/stop-job" -H "Content-Type: application/json" -d "{\"jobId\": \"${name}\"}" | jq '.'

job.submit.file:
	@echo "Submitting job file:"
	curl ${CA_CERT} ${CURL_USER} --location '${baseUrl}/submit-job/upload' --form 'config_file=@"${name}"'

job.submit:
	@echo "Submitting job file:"
	CONN_FILE=$(shell pwd)/${name}; \
	CONN=$$(cat $${CONN_FILE}); \
	echo "Creating connector $${name}"; \
	echo "$${CONN}"; \
	curl -X POST ${CURL_USER} ${baseUrl}/submit-job/upload ${CURL_USER} -H 'Content-Type: text/plain' -d "$${CONN}" | jq '.'




###:
#         CONN_FILE=$(shell pwd)/${name}; \
#         CONN=$$(cat $${CONN_FILE}); \
#         echo "Creating connector $${name}"; \
#         curl -k -X POST "${baseUrl}/${objUrl}" -H 'Content-Type: text/plain' -d "$${CONN}" | jq '.'

#  curl -k -X POST "${baseUrl}/${objUrl}" -H 'Content-Type: application/json' -d "$${CONN}" | jq '.'
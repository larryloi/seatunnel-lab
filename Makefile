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

CT_HOME=/opt/seatunnel

# Colors for output
RED := \033[31m
GREEN := \033[32m
YELLOW := \033[33m
BLUE := \033[34m
MAGENTA := \033[35m
CYAN := \033[36m
WHITE := \033[37m
RESET := \033[0m

.PHONY: help up down ps logs shell build build.mysql network.create volume.rm.all volume.list ct.job.submit system.info job.list job.info job.stop job.submit job.log stop env

help:
	@echo "$(GREEN)Available targets:$(RESET)"
	@echo "  up                - Start container (optionally ct=<container>)"
	@echo "  down              - Stop and remove container (optionally ct=<container>)"
	@echo "  ps                - List containers"
	@echo "  logs              - Follow logs (optionally ct=<container>)"
	@echo "  shell            - Open a shell in the container (optionally ct=<container>)"
	@echo "  build             - Build the Seatunnel KAS image"
	@echo "  build.mysql      - Build the MySQL image"
	@echo "  network.create   - Create the Docker network"
	@echo "  volume.rm.all    - Remove all dangling Docker volumes"
	@echo "  volume.list      - List all Docker volumes"
	@echo "  ct.job.submit    - Submit a job to Seatunnel KAS (ct=<container>)"
	@echo "  system.info  - Get system information from Seatunnel KAS"
	@echo "  job.list     - List running jobs in Seatunnel KAS"
	@echo "  job.info     - Get information about a specific job (name=<job_id>)"
	@echo "  job.stop     - Stop a specific job (name=<job_id>)"
	@echo "  job.submit   - Submit a job file (name=<path_to_job_file>)"
	@echo "  job.log      - Fetch logs for a specific job (name=<job_id>)"
	@echo "  help              - Show this help message"

network.create:
	docker network create --driver bridge --subnet 172.199.0.0/24 --gateway 172.199.0.1 integration || true

build.mysql:
	docker build -t seatunnel-mysql:0.1.0 -f ./Dockerfiles/Dockerfile-mysql .

build:
	docker build -t seatunnel-$(SEATUNNEL_VER)-kas:latest -f ./Dockerfiles/Dockerfile-seatunnel-kas .

volume.rm.all:
	docker volume rm $$(docker volume ls -qf dangling=true)

volume.list:
	docker volume ls

.PHONY: up
ps:
	$(print_vars)
	@echo "$(GREEN)All Services Status:$(RESET)"
	docker compose ps -a

up:
	@echo "$(GREEN)Starting $(db) services...$(RESET)"
	docker compose up -d $(CONTAINER_ARG)
	@echo "$(GREEN)✓ Services started successfully$(RESET)"

stop:
	@echo "$(YELLOW)Stopping $(db) services...$(RESET)"
	docker compose stop $(CONTAINER_ARG)
	@echo "$(GREEN)✓ Services stopped successfully$(RESET)"

down:
	@echo "$(RED)Stopping and removing $(db) services...$(RESET)"
	docker compose down $(CONTAINER_ARG)
	@echo "$(GREEN)✓ Services stopped and removed successfully$(RESET)"

logs:
	docker compose logs -f $(CONTAINER_ARG)

shell:
	@echo "$(GREEN)Opening shell in $(CONTAINER_ARG) container...$(RESET)"
	docker compose exec $(CONTAINER_ARG) bash



ct.job.submit:
	@echo "$(GREEN)Submitting job file to Seatunnel KAS in container $(ct)...$(RESET)"
	@if [ -z "$(ct)" ]; then \
		echo "$(RED)Error: 'ct' variable is not set. Please specify the container using 'ct=<container_name>'$(RESET)"; \
		exit 1; \
	fi
	@if [ -z "$(name)" ]; then \
		echo "$(RED)Error: 'name' variable is not set. Please specify the job file using 'name=<path_to_job_file>'$(RESET)"; \
		exit 1; \
	fi
	@echo "$(GREEN)Using job file: $(name)$(RESET)"
	@echo "$(GREEN)Using container: $(ct)$(RESET)"
	# Copy the job file into the container
	docker cp $(name) $(ct):${CT_HOME}/$(notdir $(name))
	# Execute the job submission command inside the container
	docker compose exec ${DEFAULT_MASTER} bin/seatunnel.sh -c ${CT_HOME}/$(shell basename $(name)) 

system.info:
	@echo "$(GREEN)System information:$(RESET)"
	curl --fail --silent --show-error ${CA_CERT} ${CURL_SECRET} -X GET "${baseUrl}/system-monitoring-information" | jq '.'

job.list:
	@echo "$(GREEN)Running jobs:$(RESET)"
	curl --fail --silent --show-error ${CA_CERT} ${CURL_SECRET} -X GET ${CURL_SECRET} ${baseUrl}/running-jobs | jq -r '["JOB ID", "JOB NAME", "STATUS"], (.[] | [.jobId, .jobName, .jobStatus]) | @tsv ' | column -s : -t| sed 's/\"//g'

job.info:
	@echo "$(GREEN)Job information:$(RESET)"
	@echo "Job ID: ${name}"
	curl --fail --silent --show-error ${CA_CERT} ${CURL_SECRET} -X GET ${CURL_SECRET} "${baseUrl}/job-info/${name}" | jq -r '["JOB ID", "JOB NAME", "STATUS", "START TIME", "END TIME"], [.jobId, .jobName, .jobStatus, .startTime, .endTime] | @tsv '| column -s : -t | sed 's/\"//g'

job.stop:
	@echo "$(GREEN)Stopping job:$(RESET)"
	@echo "Job ID: ${name}"
	curl --fail --silent --show-error ${CA_CERT} ${CURL_SECRET} -X POST ${CURL_SECRET} "${baseUrl}/stop-job" -H "Content-Type: application/json" -d "{\"jobId\": \"${name}\"}" | jq '.'

job.submit:
	@echo "$(GREEN)Submitting job file:$(RESET)"
	curl --fail --silent --show-error ${CA_CERT} ${CURL_SECRET} --location '${baseUrl}/submit-job/upload' --form 'config_file=@"${name}"'

job.log:
	@echo "$(GREEN)Fetching job log:$(RESET)	@echo ""	@echo "Makefile variables:""
	curl --fail --silent --show-error ${CA_CERT} ${CURL_SECRET} -X GET ${CURL_SECRET} "${baseUrl}/logs/${name}" 


# ===================================
# Environment Targets
# ===================================

.PHONY: env
env: ## Show environment configuration
	@echo "$(GREEN)Environment Configuration:$(RESET)"
	@echo "  SEATUNNEL_VER: $(SEATUNNEL_VER)"
	@echo "  DEFAULT_MASTER: $(DEFAULT_MASTER)"
	@echo "  CT (Container): $(if $(ct),$(ct),<not set>)"
	@echo "  CA_CERT: $(if $(CA_CERT),$(CA_CERT),<not set>)"
	@echo "  CURL_SECRET: $(if $(CURL_SECRET),$(CURL_SECRET),<not set>)"
	@echo "  baseUrl: $(if $(baseUrl),$(baseUrl),<not set>)"
	@echo "  name: $(if $(name),$(name),<not set>)"
	@echo ""	@echo "Makefile variables:"
	$(foreach var,$(VARS_TO_PRINT),\
		echo "  $(var) = $($(var))\n"\
	)


# job.submit:
# 	@echo "Submitting job file:"
# 	CONN_FILE=$(shell pwd)/${name}; \
# 	CONN=$$(cat $${CONN_FILE}); \
# 	echo "Creating connector $${name}"; \
# 	echo "$${CONN}"; \
# 	curl ${CA_CERT} ${CURL_SECRET} -X POST ${baseUrl}/submit-job/upload ${CURL_SECRET} -H 'Content-Type: application/json' -d "$${CONN}" | jq '.'

###:
#         CONN_FILE=$(shell pwd)/${name}; \
#         CONN=$$(cat $${CONN_FILE}); \
#         echo "Creating connector $${name}"; \
#         curl -k -X POST "${baseUrl}/${objUrl}" -H 'Content-Type: text/plain' -d "$${CONN}" | jq '.'

#  curl -k -X POST "${baseUrl}/${objUrl}" -H 'Content-Type: application/json' -d "$${CONN}" | jq '.'
#
#
# SHELL := /bin/bash
# .SHELLFLAGS := -eo pipefail -c

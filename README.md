# Seatunnel Lab (seatunnel-study)

This repository contains Docker and Makefile utilities to run and test Apache SeaTunnel KAS (Kafka-aware Seatunnel) locally. It bundles Docker Compose definitions, helper scripts, Dockerfiles for custom images (including a MySQL image), and a convenient `Makefile` to manage common tasks.

Use this repo to stand up a quick integration environment for local development, to build test images, submit jobs to Seatunnel KAS, and call the KAS REST API for job management.

## Contents

- `docker-compose*.yaml` - several docker-compose variants for different test durations and topologies.
- `Dockerfiles/` - Dockerfiles for building custom images (seatunnel-kas and a MySQL image).
- `Makefile` - convenience targets for starting/stopping services, building images, submitting jobs, and calling the KAS API.
- `config/`, `job/`, `lib/`, `starter/` - sample configs, job definitions, and supporting files.

## Prerequisites

Make sure you have the following installed on your development machine:

- Docker (with Compose V2: `docker compose` subcommand)
- GNU Make
- curl
- jq
- column (optional, used for pretty-printing in some Makefile targets)

If you are on Linux, ensure you can run Docker commands as your user or use `sudo`.

## Quick start

1. Copy or create a `Makefile.env` in the repository root (there is a template in the repo). This file defines variables like `SEATUNNEL_VER`, `DEFAULT_MASTER`, and API variables used by the Makefile. Example minimal `Makefile.env`:

```
SEATUNNEL_VER=2.0.0
DEFAULT_MASTER=master1
# baseUrl should point to your Seatunnel KAS HTTP API endpoint, e.g.: http://localhost:8080/api
baseUrl=http://localhost:8080/api
# Optional TLS and auth
CA_CERT=
CURL_SECRET=
```

2. Start the services (run optionally with `ct` to target a specific container):

```
make up
# or to start a single service (example):
make up ct=master1
```

3. Check status and logs:

```
make ps
make logs ct=master1
```

4. Submit a job file to Seatunnel KAS:

```
make ct.job.submit ct=master1 name=job/myjob.conf
```

## Important Makefile targets

- `make help` — show the help text with the available targets.
- `make up` — bring up containers using `docker compose up -d`.
- `make down` — bring down and remove containers.
- `make ps` — show `docker compose ps -a` output.
- `make logs` — follow logs; optionally pass `ct=<container>` to limit logs to one container.
- `make shell` — open a shell into the configured container (pass `ct=<container>`).
- `make build` — build the SeaTunnel KAS image from `Dockerfiles/Dockerfile-seatunnel-kas` (uses `SEATUNNEL_VER`).
- `make build.mysql` — build the MySQL helper image.
- `make network.create` — create the Docker network used by the compose stacks.
- `make volume.rm.all` — remove dangling volumes.

API helpers (require `Makefile.env` with `baseUrl` and optional `CA_CERT`/`CURL_SECRET`):

- `make api.system.info` — GET system monitoring info from KAS.
- `make api.job.list` — list running jobs.
- `make api.job.info name=<job_id>` — get info about a job.
- `make api.job.stop name=<job_id>` — stop a running job.
- `make api.job.submit name=<path_to_job_file>` — submit a job file to the REST endpoint.
- `make api.job.log name=<job_id>` — fetch job logs.

## Environment variables

The Makefile loads `Makefile.env`. Useful variables:

- `SEATUNNEL_VER` — SeaTunnel version used to tag the built KAS image.
- `DEFAULT_MASTER` — the compose service name to target for operations that act on the server.
- `ct` — (override on the command line) container/service name to act on, e.g. `ct=master1`.
- `baseUrl` — Seatunnel KAS HTTP API base URL for the `api.*` targets.
- `CA_CERT` / `CURL_SECRET` — optional curl arguments for TLS client certs or auth headers.

Examples:

```
make api.job.list
make api.job.info name=1234-abcd
make api.job.submit name=job/myjob.conf
```

## Troubleshooting

- If `docker compose` is not found, ensure you have Docker Compose V2 or adjust the Makefile to use `docker-compose` if you have the legacy plugin.
- If `make ct.job.submit` fails, ensure `ct` and `name` are provided and the job file path is correct.
- Some API helpers expect `jq` and `column` to be installed. If you don't have them, install (`sudo apt install jq bsdmainutils`) or modify the Makefile to remove those pipes.

## Suggested improvements (if you want to contribute)

- Add an explicit `check-deps` target to verify Docker, jq, curl, and column are installed.
- Add `.DEFAULT_GOAL := help` so running `make` with no args shows help.
- Make `DEFAULT_MASTER` and other service names configurable and centralised; avoid hard-coded service names in recipes.

## Contributing

Feel free to open issues or PRs in this repository. Keep changes small and document behaviour in `Makefile` comments.

## License

This repo inherits the license of the upstream project—please check repository root for a LICENSE file or ask the maintainers.



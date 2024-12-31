
ps:
	docker compose ps

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f

shell.master:
	docker compose exec master bash

shell.worker1:
	docker compose exec worker1 bash

shell.worker2:
	docker compose exec worker2 bash


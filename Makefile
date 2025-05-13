COMPOSE_CMD = docker compose -f container/docker-compose.yml
RUN_SERVICE_B_CMD = $(COMPOSE_CMD) run service_b mix
RUN_SERVICE_A_CMD = $(COMPOSE_CMD) run service_a mix

# Build all services
build:
	$(COMPOSE_CMD) build

# Start all services
up:
	$(COMPOSE_CMD) up

# create database
create-db:
	$(RUN_SERVICE_B_CMD) ecto.create

# migrate database
migrate-db:
	$(RUN_SERVICE_B_CMD) ecto.migrate

# create fake users
create-users:
	$(RUN_SERVICE_B_CMD) run -e AppWeb.PageController.create_users

get-deps-a:
	$(RUN_SERVICE_A_CMD) deps.get

get-deps-b:
	$(RUN_SERVICE_B_CMD) deps.get
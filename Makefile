COMPOSE_CMD = docker compose -f container/docker-compose.yml
RUN_SERVICE_B_CMD = $(COMPOSE_CMD) run service_b mix
# Build all services
build:
	$(COMPOSE_CMD) build

# Start all services
up:
	$(COMPOSE_CMD) up

# create database
create-db:
	$(RUN_SERVICE_B_CMD) mix ecto.create

# migrate database
migrate-db:
	$(RUN_SERVICE_B_CMD) mix ecto.migrate

# create fake users
create-users:
  $(RUN_SERVICE_B_CMD) run -e AppWeb.PageController.create_users
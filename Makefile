COMPOSE_CMD = docker compose -f container/docker-compose.yml

# Build all services
build:
	$(COMPOSE_CMD) build

# Start all services
up:
	$(COMPOSE_CMD) up

# create database
create-db:
	$(COMPOSE_CMD) run service_b mix ecto.create

# migrate database
migrate-db:
	$(COMPOSE_CMD) run service_b mix ecto.migrate

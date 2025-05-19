# Idea
## Service A
Service A takes in a yaml file with a given datastructure (table_name & columns). Then this datastructure is saved in redis. This service is an Elixir Phoenix application, which uses redis.

## Service B
This service reads the datastructure from redis. With this information it can process API http endpoints (`/api/<model_name>`) to query the instances from the database. This route will also get the column names from redis and queries only those columns

It will also have a `/api/table_names` route, which will return all table names

## Frontend
This is a simple React/Typescript application. This will do api calls to Service A & B.

## Redis
This is just a simple redis container from the latest redis image. Both Elixir apps can access it. Redix is used for accessing the redis instance.

## Postgres
For relational db Postgresql is used. Only Service B uses this. A simple postgres container from the latest postgres image is used.

# Instructions
## Installation / Preparation
- run `make build` to install the services
- run `make create-db` to create the database
- run `make migrate-db` to migrate the database
- run `make create-users` to create fake users

## Run the services
- run `make up` to start all services
- `service_a` will run on localhost:4001
- `service_b` will run on localhost:4000
- `frontend` will run on localhost:3000

## Improvements
- [ ] move create users to better location, something like script.exs somewhere?
- [ ] add docstrings to functions: describe fn, params and return info
- [ ] Service A doesn't need Phoenix / to be a web server. Since it only has to execute a task (read from file -> save to redis)

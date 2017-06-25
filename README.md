# Pairmotron

[![Build Status](https://travis-ci.org/ElixirCLE/pairmotron.svg?branch=master)](https://travis-ci.org/ElixirCLE/pairmotron)

Pairmotron is an app powered by [Phoenix](http://www.phoenixframework.org/) that randomly pairs up users within groups on a weekly basis to work on a project or just write some code!

## Local Installation

### Prerequisites

  * Elixir >= 1.4.0
  * PostgreSQL
  
### Running it

  * Install dependencies with `mix deps.get`
  * Setup environment variables for your PostgreSQL user (PG_USER) and password (PG_PASSWORD)
    * On Mac or Linux add this to your .bashrc or .zshrc:
```
export DB_ENV_POSTGRES_USER="example_username"
export DB_ENV_POSTGRES_PASSWORD="example_password"
```
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

## Developing and Testing with Docker

Using this model of development allows you to not install anything other
than docker.

### Running it
  * docker-compose up -d web
  * docker-compose exec web mix deps.get
  * docker-compose exec web mix ecto.create 
  * docker-compose exec web mix ecto.migrate
  * docker-compose exec web npm install
  * docker-compose restart web

### Run the Tests in Docker
  * docker-compose run -e "MIX_ENV=test" web mix test 
  * Only test a specific test file
    * docker-compose run -e "MIX_ENV=test" web mix test/controllers/group_controller_test.exs
  
## Check it out in a browser

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Deploy to Production
Ready to run in production? 
* Please [check the phoenix deployment guides](http://www.phoenixframework.org/docs/deployment).
* Set the environment variable (SECRET_KEY_BASE) used for session cookies.
* Set the environment variable (GUARDIAN_JWK_KEY) for the secret key which guardian uses for JWT tokens.



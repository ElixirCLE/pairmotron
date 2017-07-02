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

## Ready to run in production?
* Please [check the phoenix deployment guides](http://www.phoenixframework.org/docs/deployment).

### Environment Variables to set

* SECRET_KEY_BASE - Used to generate session cookies.
* PAIRMOTRON_EMAIL_DOMAIN - The domain configured in Mailgun to send password reset email.
* PAIRMOTRON_MAILGUN_API_KEY - The API key given by Mailgun for the configured domain.

### JWT Key Configuration

Pairmotron uses the ES512 algorithm to generate JSON Web Tokens. You will need to generate a key and set the appropriate environment variables.

To generate a key do the following from the root pairmotron directory:

```elixir
iex -S mix

iex> JOSE.JWK.generate_key({:ec, "P-521"}) |> JOSE.JWK.to_map
{%{kty: :jose_jwk_kty_ec},
 %{"crv" => "P-521",
   "d" => "Ae-wdbGhjfpxapevgJDAxaiGHmKYoyWnYDLeAb9jALSBNBzkyelSL-FUHcdFw1B7V2FvPy3YaHEkrVqwPwBwNvLP",
   "kty" => "EC",
   "x" => "AWFw34kJJaT8Lwew8IG4LcDDr8sMcURn4PhUWMBiMW5vGGonteVvZQAVdW652GFOY9z1nlhymKYXBwNy3PHlz9Z_",
   "y" => "APLY5Rww4oI1fhUI7JrIkmHPymzgpGOKsNXHhxoMJDycdoQPWfaimoOX-afOHoJiGWwh2m_EbTSC-4lC4Cz0uzPk"}}
```

And then set the following environment variables:
* GUARDIAN_JWK_ES512_D - The "d" value of the key generated above.
* GUARDIAN_JWK_ES512_X - The "x" value of the key generated above.
* GUARDIAN_JWK_ES512_Y - The "y" value of the key generated above.

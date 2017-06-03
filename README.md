# Pairmotron

[![Build Status](https://travis-ci.org/ElixirCLE/pairmotron.svg?branch=master)](https://travis-ci.org/ElixirCLE/pairmotron)

Pairmotron is an app powered by [Phoenix](http://www.phoenixframework.org/) that randomly pairs up users within groups on a weekly basis to work on a project or just write some code!

## Installation

### Prerequisites

  * Elixir >= 1.4.0
  * PostgreSQL

### Running it

  * Install dependencies with `mix deps.get`
  * Setup environment variables for your PostgreSQL user (PG_USER) and password (PG_PASSWORD)
    * On Mac or Linux add this to your .bashrc or .zshrc:
```
export PG_USER="example_username"
export PG_PASSWORD="example_password"
```
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Ready to run in production?
* Please [check the phoenix deployment guides](http://www.phoenixframework.org/docs/deployment).

### Environment Variables to set

* SECRET_KEY_BASE - Used to generate session cookies.
* GUARDIAN_JWK_KEY - Used to generate JWT tokens.
* PAIRMOTRON_EMAIL_DOMAIN - The domain configured in Mailgun to send password reset email.
* PAIRMOTRON_MAILGUN_API_KEY - The API key given by Mailgun for the configured domain.


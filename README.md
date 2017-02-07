# Juggler
A simple elixir/phoenix based deployment tool.

## Install
- dcg build
- dcg up -d
- dcg run web mix deps.get
- dcg run web npm Install
- dcg run web node node_modules/brunch/bin/brunch build
- dcg run web mix ecto.create
- dcg run web mix ecto.migrate
- dcg up -d

## Configure
- create .env file based on sample.env

## TODO
- stream command output
- git integration
- servers/deploys
- vue js
- project channel to update build states and builds
- edit profile, forgot password

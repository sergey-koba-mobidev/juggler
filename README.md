# Juggler
A simple Elixir/Phoenix + Docker based continuous integration tool.

![Juggler example](http://s.pictub.club/2017/03/06/slLW55.png)

## Install
- create `.env` file based on `sample.env`
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

## Usage
- Go to [http://localhost:4000](http://localhost:4000)
- To see queues and jobs go to [http://localhost:4000/verk/queues](http://localhost:4000/verk/queues)

## Alpha Roadmap
- stream command output + timeout on user input
- faq and terms pages

## Roadmap
- integrations (notification to slack, hipchat)
- organizations
- tests
- email notifications about failed builds/deploys
- notifications settings
- build and deploys to vue js

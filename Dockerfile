FROM elixir:1.4.0

ENV DEBIAN_FRONTEND=noninteractive

# Install Docker client
RUN curl -sSL https://get.docker.com/ | sh

# Install hex
RUN mix local.hex --force

# Install rebar
RUN mix local.rebar --force

# Install the Phoenix framework itself
RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez

# Install NodeJS 6.x and the NPM
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install -y -q nodejs

# Copy app code
COPY . /app

EXPOSE 4000

# Set /app as workdir
WORKDIR /app

# Production
# Initial setup
RUN mix deps.get --only prod
RUN MIX_ENV=prod mix compile

# Compile assets
RUN brunch build --production
RUN MIX_ENV=prod mix phoenix.digest

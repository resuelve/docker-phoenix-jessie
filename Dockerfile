FROM buildpack-deps:jessie

# Elixir requires UTF-8
RUN apt-get update && apt-get upgrade -y && apt-get install locales && locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# update and install software
RUN apt-get install -y curl wget git make sudo
    # download and install Erlang apt repo package
RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb \
    && dpkg -i erlang-solutions_1.0_all.deb \
    && apt-get install -y software-properties-common \
    && apt-get update -y \
    && apt-get upgrade -y \
    && rm erlang-solutions_1.0_all.deb \
    # For some reason, installing Elixir tries to remove this file
    # and if it doesn't exist, Elixir won't install. So, we create it.
    # Thanks Daniel Berkompas for this tip.
    # http://blog.danielberkompas.com
    && touch /etc/init.d/couchdb \
    # install latest elixir package
    && apt-get install -y libstdc++6 \
    && apt-get install -y elixir erlang-dev erlang-dialyzer erlang-parsetools \
    # clean up after ourselves
    && apt-get clean

# install the Phoenix Mix archive
RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/1.3-rc/phx_new-1.3.0-rc.2.ez
RUN mix local.hex --force \
    && mix local.rebar --force

# install Node.js (>= 6.0.0) and NPM in order to satisfy brunch.io dependencies
# See http://www.phoenixframework.org/docs/installation#section-node-js-5-0-0-
RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - && sudo apt-get install -y nodejs

VOLUME /app/src/deps
VOLUME /app/src/_build

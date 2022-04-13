FROM elixir:latest

RUN apt-get update && \
    apt-get install -y postgresql-client && \
    apt-get install -y inotify-tools && \
    apt-get install build-essential && \
    mix local.hex --force && \
    mix archive.install hex phx_new 1.5.8 --force && \
    mix local.rebar --force

ENV APP_HOME /home/app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

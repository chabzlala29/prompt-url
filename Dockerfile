# Launch the server (or run some other Ruby command)
FROM ruby:latest

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock

WORKDIR /app

RUN bundle install
COPY app /app

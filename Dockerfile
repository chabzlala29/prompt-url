# Launch the server (or run some other Ruby command)
FROM ruby:2.7.1

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock

RUN bundle config set force_ruby_platform true

WORKDIR /app

RUN bundle install
COPY app /app

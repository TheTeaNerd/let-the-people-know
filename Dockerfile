FROM ruby:3.2.0-alpine

ENV APP_HOME /app
WORKDIR ${APP_HOME}

COPY Gemfile \
     Gemfile.lock \
     action.rb \
     action.yml ${APP_HOME}/

RUN bundle install --without development test

COPY entrypoint /entrypoint

ENTRYPOINT ["/entrypoint"]

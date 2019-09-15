FROM ruby:2.6.4-alpine

ENV APP_HOME /app
WORKDIR ${APP_HOME}

COPY Gemfile \
     Gemfile.lock \
     action.rb \
     action.yml ${APP_HOME}/

RUN bundle install

COPY entrypoint /entrypoint

ENTRYPOINT ["/entrypoint"]

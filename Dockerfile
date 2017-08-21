FROM ruby:2.2.6
MAINTAINER Andre LeBlanc <andre.leblanc88@gmail.com>

RUN apt-get update

WORKDIR /druiddb-ruby

COPY lib/druiddb/version.rb lib/druiddb/version.rb
COPY druiddb.gemspec druiddb.gemspec
COPY Gemfile Gemfile

RUN git init
RUN bundle install

COPY bin bin
COPY lib lib
COPY spec spec
COPY Rakefile Rakefile

CMD bin/console

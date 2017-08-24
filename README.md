# druiddb-ruby

[![Build Status](https://travis-ci.org/andremleblanc/druiddb-ruby.svg?branch=master)](https://travis-ci.org/andremleblanc/druiddb-ruby)
[![Gem Version](https://badge.fury.io/rb/druiddb.svg)](https://badge.fury.io/rb/druiddb)
[![Code Climate](https://codeclimate.com/github/andremleblanc/druiddb-ruby/badges/gpa.svg)](https://codeclimate.com/github/andremleblanc/druiddb-ruby)
[![Dependency Status](https://gemnasium.com/badges/github.com/andremleblanc/druiddb-ruby.svg)](https://gemnasium.com/github.com/andremleblanc/druiddb-ruby)

This documentation is intended to be a quick-start guide, not a comprehensive
list of all available methods and configuration options. Please look through
the source for more information; a great place to get started is `DruidDB::Client`
and the `DruidDB::Query` modules as they expose most of the methods on the client.

This guide assumes a significant knowledge of Druid, for more info:
http://druid.io/docs/latest/design/index.html

## What Does it Do

druiddb-ruby provides a client for your Ruby application to push data to Druid leveraging the [Kafka Indexing Service](http://druid.io/docs/latest/development/extensions-core/kafka-ingestion.html). The client also provides an interface for querying and performing management tasks. It will automatically find and connect to Kafka and the Druid nodes through ZooKeeper, which means you only need to provide the ZooKeeper host and it will find everything else.

## Install

```bash
$ gem install druiddb
```

## Usage

### Creating a Client
```ruby
client = DruidDB::Client.new()
```
*Note:* There are many configuration options, please take a look at
`DruidDB::Configuration` for more details.

### Writing Data

#### Kafka Indexing Service
This gem leverages the [Kafka Indexing Service](http://druid.io/docs/latest/development/extensions-core/kafka-ingestion.html) for ingesting data. The gem pushes datapoints onto Kafka topics (typically named after the datasource). You can also use the gem to upload an ingestion spec, which is needed for Druid to consume the Kafka topic.

This repo contains a `docker-compose.yml` build that may help bootstrap development with Druid and the Kafka Indexing Service. It's what we use for integration testing.

#### Submitting an Ingestion Spec

```ruby
path = 'path/to/spec.json'
client.submit_supervisor_spec(path)
```

####  Writing Datapoints
```ruby
topic_name = 'foo'
datapoint = {
  timestamp: Time.now.utc.iso8601,
  foo: 'bar',
  units: 1
}
client.write_point(topic_name, datapoint)
```

### Reading Data

#### Querying
```ruby
client.query(
  queryType: 'timeseries',
  dataSource: 'foo',
  granularity: 'day',
  intervals: Time.now.utc.advance(days: -30) + '/' + Time.now.utc.iso8601,
  aggregations: [{ type: 'longSum', name: 'baz', fieldName: 'baz' }]
)
```
The `query` method POSTs the query to Druid; for information on
querying Druid: http://druid.io/docs/latest/querying/querying.html. This is
intentionally simple to allow all current features and hopefully all future
features of the Druid query language without updating the gem.

##### Fill Empty Intervals

Currently, Druid will not fill empty intervals for which there are no points. To
accommodate this need until it is handled more efficiently in Druid, use the
experimental `fill_value` feature in your query. This ensure you get a result
for every interval in intervals.

This has only been tested with 'timeseries' and single-dimension 'groupBy'
queries with simple granularities.

```ruby
client.query(
  queryType: 'timeseries',
  dataSource: 'foo',
  granularity: 'day',
  intervals: Time.now.utc.advance(days: -30) + '/' + Time.now.utc.iso8601,
  aggregations: [{ type: 'longSum', name: 'baz', fieldName: 'baz' }],
  fill_value: 0
)
```

### Management
List datasources.
```ruby
client.list_datasources
```

List supervisor tasks.
```ruby
client.supervisor_tasks
```

## Development

### Docker Compose
This project uses docker-compose to provide a development environment.

1. git clone the project
2. cd into project
3. `docker-compose up` - this will download necessary images and run all dependencies in the foreground.

Then you can use `docker build -t some_tag .` to build the Docker image for this project after making changes and `docker run -it --network=druiddbruby_druiddb some_tag some_command` to interact with it.

### Metabase

Viewing data in the database can be a bit annoying, use a tool like [Metabase](https://github.com/metabase/metabase) makes this much easier and is what I personally do when developing.

## Testing

Testing is run utilizing the docker-compose environment.

1. `docker-compose up`
2. `docker run -it --network=druiddbruby_druiddb druiddb-ruby bin/run_tests.sh`

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

# TODO:
- Update write (no nesting)
- Shout to Metabase
- Testing
  - Run docker
  - curl
# druiddb-ruby

This documentation is intended to be a quick-start guide, not a comprehensive
list of all available methods and configuration options. Please look through
the source for more information; a great place to get started is `DruidDB::Client`
and the `DruidDB::Query` modules as they expose most of the methods on the client.

This guide assumes a significant knowledge of Druid, for more info:
http://druid.io/docs/latest/design/index.html

## Install

```
$ gem install druiddb
```

## Usage

### Creating a Client
```
# With default configuration:
client = DruidDB::Client.new
```
*Note:* There are many configuration options, please take a look at
`DruidDB::Configuration` for more details.

## Writing Data

Write a datapoint:
```
datasource_name = 'foo'
datapoint = {
  timestamp: Time.now.utc, # Optional: Defaults to Time.now.utc
  dimensions: { foo: 'bar' }, # Arbitrary key-value tags
  metrics: { baz: 1 } # The values being measured
}
client.write_point(datasource_name, datapoint)
```
*Note:* The `write_point` utilizes the
[Tranquility Core API](https://github.com/druid-io/tranquility/blob/master/docs/core.md)
to communicate with Druid. The Tranquility API handles a lot of concerns like
buffering, service discovery, schema rollover etc. The main features of
the `write_point` method are 1) creation of the data schema and 2) detecting
schema change to support automatic schema evolution.

Basically, when you write a point with the `write_point` method, it will compare
the point with the current schema (if present) and create a new Tranquilizer
(connection to Druid) with the new schema if needed. This all happens
seamlessly without your application needing to know anything about schema.

The expectation is the schema changes infrequently and subsequent writes after
a schema change have the same schema.

## Reading Data

Querying:
```
start_time = Time.now.utc.advance(days: -30)

client.query(
  queryType: 'timeseries',
  dataSource: 'foo',
  granularity: 'day',
  intervals: start_time.iso8601 + '/' + Time.now.utc.iso8601,
  aggregations: [{ type: 'longSum', name: 'baz', fieldName: 'baz' }]
)
```
*Note:* The `query` method just POSTs the query to Druid; for information on
querying Druid: http://druid.io/docs/latest/querying/querying.html. This is
intentionally simple to allow all current features and hopefully all future
features of the Druid query language without updating the gem.

Fill Empty Intervals:

Currently, Druid will not fill empty intervals for which there are no points. To
accommodate this need until it is handled more efficiently in Druid, use the
experimental `fill_value` feature in your query. This ensure you get an result
for every interval in intervals.

This has only been tested with 'timeseries' and single-dimension 'groupBy'
queries with simple granularities.
```
start_time = Time.now.utc.advance(days: -30)

client.query(
  queryType: 'timeseries',
  dataSource: 'foo',
  granularity: 'day',
  intervals: start_time.iso8601 + '/' + Time.now.utc.iso8601,
  aggregations: [{ type: 'longSum', name: 'baz', fieldName: 'baz' }],
  fill_value: 0
)
```

## Development
Useful Docker commands:
`JMX_PORT=9999 kafka-console-consumer.sh --bootstrap-server kafka:9092 --topic xwings --from-beginning`  
`docker exec -it -e JMX_PORT=9999 druiddbruby_kafka_1 kafka-console-consumer.sh --bootstrap-server kafka:9092 --topic xwings --from-beginning`

`curl -X POST -H 'Content-Type: application/json' -d @spec/ingestion_specs/xwings_spec.json http://localhost:8090/druid/indexer/v1/supervisor`

## Testing

The tests in `/spec/druid` can be run without Druid running. The tests in
`/spec/integration` require Druid to be running.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

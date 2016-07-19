# jruby-druid

## Foreword
This documentation is intended to be a quick-start guide, not a comprehensive
list of all available methods and configuration options. Please look through
the source for more information; a great place to get started is `Druid::Client`
and the `Druid::Query` modules as they expose most of the methods on the client.

Further, this guide assumes a significant knowledge of Druid, for more info:
http://druid.io/docs/latest/design/index.html

## Install

```
$ gem install jruby-druid
```

## Usage

### Creating a Client
```
# With default configuration:
client = Druid::Client.new
```

```
# With custom tuning_granularity:
client = Druid::Client.new(tuning_granularity: :hour)
```
*Note:* There are many configuration options, please take a look at
`Druid::Configuration` for more details.

### Administrative Tasks
Creating a datasource is handled when writing points.

Delete datasource(s):
```
# Delete a specific datasource:
datasource_name = 'foo'
client.delete_datasource(datasource_name)
```

```
# Deleting all datasources:
client.delete_datasources
```

*Note:* Deleting datasources and writing to them again can be a bit tricky in
Druid. If this is something you need to do (like in testing) then you can use
the strong_delete configuration option
(`Druid::Client.new(strong_delete: true)`). This setting is not recommend for
production since it uses randomizeTaskIds in the DruidBeamConfig which can lead
to race conditions.

List datasources:
```
client.list_datasources
```

Shutdown tasks:
```
client.shutdown_tasks
```

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

## Testing

The tests in `/spec/druid` can be run without Druid running. The tests in
`/spec/integration` require Druid to be running.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Credit

This project is somewhat modeled after the
[influxdb-ruby](https://github.com/influxdata/influxdb-ruby) adapter, just
wanted to give a shout out for their work.

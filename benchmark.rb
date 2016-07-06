require 'benchmark'
require 'influxdb'
require 'jruby-druid'

@max = 100000
# 100000 points | druid: 154.772s | influx: 246.821s
# 100000 points | druid: 208.095s | influx: 244.993s - Schema Change Detection

def run_druid_benchmark
	attempts = 0
	config = { tuning_granularity: :hour, tuning_window: 'PT1M' }
	client = Druid::Client.new(config)
	datasource = 'foobar'
	dimensions = { manufacturer: 'ACME', owner: 'Wile E. Coyote' }
	metrics = { anvils: 1 }
	datapoint = { dimensions: dimensions, metrics: metrics }

	until attempts >= @max
		attempts += 1
		puts "druid attempt #{attempts}" if attempts % 100 == 0
		client.write_point(datasource, datapoint)
	end
end

def run_influx_benchmark
	client = InfluxDB::Client.new 'aview_measurements_test'
	name = 'foobar'
	attempts = 0
	data = {
		values: { anvils: 1 },
		tags: { manufacturer: 'ACME' }
	}

	until attempts >= @max
		attempts += 1
		puts "influx attempt #{attempts}" if attempts % 100 == 0
		client.write_point(name, data)
	end
end

druid_time = Benchmark.realtime { run_druid_benchmark }
influx_time = Benchmark.realtime { run_influx_benchmark }
puts "#{@max} points | druid: #{druid_time}s | influx: #{influx_time}s"

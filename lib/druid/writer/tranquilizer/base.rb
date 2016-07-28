# Based on Java Example below
# https://github.com/gianm/tranquility-example/blob/master/src/main/java/io/imply/tranquility/JavaExample.java

module Druid
  module Writer
    module Tranquilizer
      class Base
        attr_reader :config,
                    :curator,
                    :datasource,
                    :rollup,
                    :service,
                    :tuning

        def initialize(params)
          @config = params[:config]
          @datasource = params[:datasource].to_s
          @rollup = Druid::Writer::Tranquilizer::Rollup.build(config, params[:datapoint])
          @tuning = Druid::Writer::Tranquilizer::Tuning.build(config)
          @curator = Druid::Writer::Tranquilizer::Curator.build(config)
          @service = create_service

          start
        end

        def safe_send(datapoint)
          thread = Thread.new{ send(datapoint) }
          result = thread.join(@config.wait_time)
          raise Druid::ConnectionError, 'Error connecting to ZooKeeper' unless result
          Druid::Writer::Tranquilizer::Future.new(result.value)
        end

        def start
          curator.start
          service.start
        end

        def stop
          service.flush
          service.stop
          curator.close
        end

        private

        def argument_map(datapoint)
          args = datapoint.timestamp.
            merge(datapoint.dimensions).
            merge(datapoint.metrics)

          ImmutableMap.builder.putAll(args).build
        end

        def create_service
          timestamper = Timestamper.new
          timestamp_spec = TimestampSpec.new("timestamp", "auto", nil)

          builder = DruidBeams.
            timestamper_builder(timestamper).
            curator(curator).
            discoveryPath(config.discovery_path).
            location(com.metamx.tranquility.druid.DruidLocation.create(config.index_service, datasource)).
            timestampSpec(timestamp_spec).
            rollup(rollup).
            tuning(tuning)
          builder = builder.druidBeamConfig(DruidBeamConfig.build(true)) if config.strong_delete
          builder.buildTranquilizer
        end

        def send(datapoint)
          service.send(argument_map(datapoint)).addEventListener(EventListener.new)
        end
      end
    end
  end
end

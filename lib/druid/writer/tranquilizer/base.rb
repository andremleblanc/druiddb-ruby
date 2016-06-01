# Based on Java Example below
# https://github.com/gianm/tranquility-example/blob/master/src/main/java/io/imply/tranquility/JavaExample.java

module Druid
  module Writer
    module Tranquilizer
      class Base
        attr_reader :config, :curator, :datasource, :rollup, :service, :tuning

        def initialize(params)
          @config = params[:config]
          @datasource = params[:datasource].to_s
          @rollup = Druid::Writer::Tranquilizer::Rollup.build(config, params[:datapoint])
          @tuning = Druid::Writer::Tranquilizer::Tuning.build(config)
          @curator = Druid::Writer::Tranquilizer::Curator.build(config)
          @service = create_service

          start
        end

        def send(datapoint)
          args = datapoint.timestamp.flatten +
            datapoint.dimensions.flatten +
            datapoint.metrics.flatten

          service.send(ImmutableMap.of(*args)).addEventListener(EventListener.new)
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

        def create_service
          timestamper = Timestamper.new
          timestamp_spec = TimestampSpec.new("timestamp", "auto", nil)

          DruidBeams.
            timestamper_builder(timestamper).
            curator(curator).
            discoveryPath(config.discovery_path).
            location(com.metamx.tranquility.druid.DruidLocation.create(config.index_service, datasource)).
            timestampSpec(timestamp_spec).
            rollup(rollup).
            tuning(tuning).
            buildTranquilizer
        end
      end
    end
  end
end

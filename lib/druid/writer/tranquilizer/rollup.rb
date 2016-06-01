module Druid
  module Writer
    module Tranquilizer
      module Rollup
        class << self
          java_import com.metamx.tranquility.druid.DruidRollup

          def build(config, datapoint)
            dimensions = Druid::Writer::Tranquilizer::Dimensions.build(datapoint.dimensions)
            aggregators = Druid::Writer::Tranquilizer::Aggregators.build(datapoint.metrics)
            DruidRollup.create(dimensions, aggregators, get_granularity(config.rollup_granularity))
          end

          private

          def get_granularity(granularity)
            "Java::IoDruidGranularity::QueryGranularity::#{granularity}".constantize
          end
        end
      end
    end
  end
end

module Druid
  module Writer
    module Tranquilizer
      class Aggregators
        class << self
          def build(metrics)
            aggs = []
            metrics.keys.each{ |metric_name| aggs << LongSumAggregatorFactory.new(metric_name, metric_name) }
            ImmutableList.of(*aggs)
          end
        end
      end
    end
  end
end

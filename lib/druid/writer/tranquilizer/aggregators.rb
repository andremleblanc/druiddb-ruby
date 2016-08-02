module Druid
  module Writer
    module Tranquilizer
      class Aggregators
        COUNT = 'count'.freeze

        class << self
          def build(metrics)
            aggs = []
            count = metrics.delete(:count)
            aggs << CountAggregatorFactory.new(COUNT) if count.present?
            metrics.keys.each do |metric_name|
              aggs << LongSumAggregatorFactory.new(metric_name, metric_name)
            end

            ImmutableList.of(*aggs)
          end
        end
      end
    end
  end
end

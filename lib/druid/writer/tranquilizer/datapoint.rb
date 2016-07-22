module Druid
  module Writer
    module Tranquilizer
      class Datapoint
        TIMESTAMP_LABEL = 'timestamp'.freeze

        attr_reader :dimensions, :timestamp, :metrics

        def initialize(datapoint)
          @timestamp = build_time(datapoint[:timestamp])
          @dimensions = parse_dimensions(datapoint[:dimensions])
          @metrics = parse_metrics(datapoint[:metrics])
        end

        private

        def build_time(time)
          time = Time.now.utc unless time
          Hash[TIMESTAMP_LABEL, time.iso8601]
        end

        def parse_dimensions(dimensions)
          dimensions.present? ? dimensions.with_indifferent_access : {}
        end

        def parse_metrics(metrics)
          raise ValidationError, 'Must specify at least one metric' unless metrics.present?
          metrics.with_indifferent_access
        end
      end
    end
  end
end

module Druid
  module Writer
    module Tranquilizer
      class Datapoint
        TIMESTAMP_LABEL = 'timestamp'.freeze

        attr_reader :dimensions, :timestamp, :metrics

        def initialize(datapoint)
          @timestamp = build_time(datapoint[:timestamp])
          @dimensions = datapoint[:dimensions].with_indifferent_access
          @metrics = datapoint[:metrics].with_indifferent_access
        end

        private

        def build_time(time)
          time = Time.now.utc unless time
          Hash[TIMESTAMP_LABEL, time.iso8601]
        end
      end
    end
  end
end

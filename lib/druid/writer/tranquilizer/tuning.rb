module Druid
  module Writer
    module Tranquilizer
      class Tuning
        class << self
          def build(config)
            ClusteredBeamTuning.
              builder.
              segmentGranularity(get_granularity(config.tuning_granularity)).
              windowPeriod(org.joda.time.Period.new(config.tuning_window)).
              partitions(1).
              replicants(1).
              build
          end

          private

          def get_granularity(granularity)
            "Java::ComMetamxCommon::Granularity::#{granularity}".constantize
          end
        end
      end
    end
  end
end

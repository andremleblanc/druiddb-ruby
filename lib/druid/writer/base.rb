module Druid
  module Writer
    class Base
      attr_reader :config

      def initialize(config)
        @config = config
      end

      def write_point(datasource, datapoint)
        # Use Kafka
      end
    end
  end
end

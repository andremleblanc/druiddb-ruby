module Druid
  class Configuration
    BROKER_URI = 'http://localhost:8082/'.freeze
    COORDINATOR_URI = 'http://localhost:8081/'.freeze
    CURATOR_URI = 'localhost:2181'.freeze
    DISCOVERY_PATH = '/druid/discovery'.freeze
    INDEX_SERVICE = 'druid/overlord'.freeze
    OVERLORD_URI = 'http://localhost:8090/'.freeze
    ROLLUP_GRANULARITY = :minute
    TUNING_GRANULARITY = :day
    TUNING_WINDOW = 'PT1H'.freeze

    attr_reader :broker_uri,
                :coordinator_uri,
                :curator_uri,
                :discovery_path,
                :index_service,
                :overlord_uri,
                :rollup_granularity,
                :tuning_granularity,
                :tuning_window


    def initialize(opts = {})
      @broker_uri = opts[:broker_uri] || BROKER_URI
      @coordinator_uri = opts[:coordinator_uri] || COORDINATOR_URI
      @curator_uri = opts[:curator_uri] || CURATOR_URI
      @discovery_path = opts[:discovery_path] || DISCOVERY_PATH
      @index_service = opts[:index_service] || INDEX_SERVICE
      @overlord_uri = opts[:overlord_uri] || OVERLORD_URI
      @rollup_granularity = rollup_granularity_string(opts[:rollup_granularity])
      @tuning_granularity = tuning_granularity_string(opts[:tuning_granularity])
      @tuning_window = opts[:tuning_window] || TUNING_WINDOW
    end

    private

    def rollup_granularity_string(input)
      output_string = input || ROLLUP_GRANULARITY
      output_string.to_s.upcase.freeze
    end

    def tuning_granularity_string(input)
      output_string = input || TUNING_GRANULARITY
      output_string.to_s.upcase.freeze
    end
  end
end

module Druid
  class Configuration
    BROKER_URI = 'http://localhost:8082/'.freeze
    COORDINATOR_URI = 'http://localhost:8081/'.freeze
    CURATOR_URI = 'localhost:2181'.freeze
    DISCOVERY_PATH = '/druid/discovery'.freeze
    INDEX_SERVICE = 'druid/overlord'.freeze
    LOG_LEVEL = :error
    OVERLORD_URI = 'http://localhost:8090/'.freeze
    ROLLUP_GRANULARITY = :minute
    STRONG_DELETE = false # Not recommend to be true for production.
    TUNING_GRANULARITY = :day
    TUNING_WINDOW = 'PT1H'.freeze
    WAIT_TIME = 20 # Seconds

    attr_reader :broker_uri,
                :coordinator_uri,
                :curator_uri,
                :discovery_path,
                :index_service,
                :log_level,
                :overlord_uri,
                :rollup_granularity,
                :strong_delete,
                :tuning_granularity,
                :tuning_window,
                :wait_time


    def initialize(opts = {})
      @broker_uri = opts[:broker_uri] || BROKER_URI
      @coordinator_uri = opts[:coordinator_uri] || COORDINATOR_URI
      @curator_uri = opts[:curator_uri] || CURATOR_URI
      @discovery_path = opts[:discovery_path] || DISCOVERY_PATH
      @index_service = opts[:index_service] || INDEX_SERVICE
      @log_level = opts[:log_level] || LOG_LEVEL
      @overlord_uri = opts[:overlord_uri] || OVERLORD_URI
      @rollup_granularity = rollup_granularity_string(opts[:rollup_granularity])
      @strong_delete = opts[:strong_delete] || STRONG_DELETE
      @tuning_granularity = tuning_granularity_string(opts[:tuning_granularity])
      @tuning_window = opts[:tuning_window] || TUNING_WINDOW
      @wait_time = opts[:wait_time] || WAIT_TIME
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

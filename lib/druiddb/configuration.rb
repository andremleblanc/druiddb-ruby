module DruidDB
  class Configuration
    CLIENT_ID = 'druiddb-ruby'.freeze
    DISCOVERY_PATH = '/druid/discovery'.freeze
    INDEX_SERVICE = 'druid/overlord'.freeze
    KAFKA_BROKER_PATH = '/brokers/ids'.freeze
    LOG_LEVEL = :error
    ROLLUP_GRANULARITY = :minute
    STRONG_DELETE = false
    TUNING_GRANULARITY = :day
    TUNING_WINDOW = 'PT1H'.freeze
    WAIT_TIME = 20
    ZOOKEEPER = 'localhost:2181'.freeze

    attr_reader :client_id,
                :discovery_path,
                :index_service,
                :kafka_broker_path,
                :log_level,
                :rollup_granularity,
                :strong_delete,
                :tuning_granularity,
                :tuning_window,
                :wait_time,
                :zookeeper

    def initialize(opts = {})
      @client_id = opts[:client_id] || CLIENT_ID
      @discovery_path = opts[:discovery_path] || DISCOVERY_PATH
      @index_service = opts[:index_service] || INDEX_SERVICE
      @kafka_broker_path = opts[:kafka_broker_path] || KAFKA_BROKER_PATH
      @log_level = opts[:log_level] || LOG_LEVEL
      @rollup_granularity = rollup_granularity_string(opts[:rollup_granularity])
      @strong_delete = opts[:strong_delete] || STRONG_DELETE
      @tuning_granularity = tuning_granularity_string(opts[:tuning_granularity])
      @tuning_window = opts[:tuning_window] || TUNING_WINDOW
      @wait_time = opts[:wait_time] || WAIT_TIME
      @zookeeper = opts[:zookeeper] || ZOOKEEPER
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

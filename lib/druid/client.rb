module Druid
  class Client
    include Druid::Logging
    include Druid::Queries::Core
    include Druid::Queries::Datasource
    include Druid::Queries::Task

    attr_reader :broker,
                :config,
                :coordinator,
                :overlord,
                :writer

    def initialize(options = {})
      @config = Druid::Configuration.new(options)
      @broker = Druid::Node::Broker.new(config)
      @coordinator = Druid::Node::Coordinator.new(config)
      setup_logger
      @overlord = Druid::Node::Overlord.new(config)
      @writer = Druid::Writer::Base.new(config)
    end

    private

    def setup_logger
      logger.set_level(config.log_level)
    end
  end
end

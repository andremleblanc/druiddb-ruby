module Druid
  class Client
    include Druid::Query::Core
    include Druid::Query::Datasource
    include Druid::Query::Task

    attr_reader :broker,
                :config,
                :coordinator,
                :overlord,
                :writer

    def initialize(options = {})
      @config = Druid::Configuration.new(options)
      @broker = Druid::Node::Broker.new(config)
      @coordinator = Druid::Node::Coordinator.new(config)
      @overlord = Druid::Node::Overlord.new(config)
      @writer = Druid::Writer::Base.new(config)
    end
  end
end

module DruidDB
  class Client
    include Druid::Queries::Core
    include Druid::Queries::Task

    attr_reader :broker,
                :config,
                :coordinator,
                :overlord,
                :writer,
                :zk

    def initialize(options = {})
      @config = Druid::Configuration.new(options)
      @zk = Druid::ZK.new(config)
      @broker = Druid::Node::Broker.new(config, zk)
      @coordinator = Druid::Node::Coordinator.new(config, zk)
      @overlord = Druid::Node::Overlord.new(config, zk)
      @writer = Druid::Writer.new(config, zk)
    end
  end
end

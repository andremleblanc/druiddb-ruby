module DruidDB
  class Client
    include DruidDB::Queries::Core
    include DruidDB::Queries::Datasources
    include DruidDB::Queries::Task

    attr_reader :broker,
                :config,
                :coordinator,
                :overlord,
                :writer,
                :zk

    def initialize(options = {})
      @config = DruidDB::Configuration.new(options)
      @zk = DruidDB::ZK.new(config)
      @broker = DruidDB::Node::Broker.new(config, zk)
      @coordinator = DruidDB::Node::Coordinator.new(config, zk)
      @overlord = DruidDB::Node::Overlord.new(config, zk)
      @writer = DruidDB::Writer.new(config, zk)
    end
  end
end

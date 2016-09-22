module Druid
  class Writer
    attr_reader :config, :producer

    def initialize(config)
      @config = config
      @producer = init_producer
    end

    def write_point(datasource, datapoint)

      # TODO: Get Kafka brokers from ZooKeeper
      producer.send_msg(datasource, nil, datapoint)
    end

    private

    def init_producer
      producer_options = {:broker_list => config.kafka_list, "serializer.class" => "kafka.serializer.StringEncoder"}
      producer = Kafka::Producer.new(producer_options)
      producer.connect()
      producer
    end
  end
end

#TODO: Seems to be a delay after shutting down Kafka and ZK updating
module Druid
  class Writer
    attr_reader :config, :producer, :zk
    def initialize(config, zk)
      @config = config
      @zk = zk
      init_producer
      zk.register_listener(self, :handle_kafka_state_change)
    end

    def write_point(datasource, datapoint)
      begin
        raise Druid::ConnectionError, 'no kafka brokers available' if producer.nil?
        producer.send_msg(datasource, nil, datapoint)
      rescue Java::KafkaCommon::FailedToSendMessageException => e
        init_producer #TODO: This may not be the best way to handle it
        producer.send_msg(datasource, nil, datapoint)
      end
    end

    private

    def broker_list
      zk.registry["/brokers/ids"].map{|instance| "#{instance[:host]}:#{instance[:port]}" }.join(',')
    end

    def handle_kafka_state_change(service)
      if service == config.kafka_broker_path
        init_producer
      end
    end

    def init_producer
      producer_options = {:broker_list => broker_list, "serializer.class" => "kafka.serializer.StringEncoder"}
      if producer_options[:broker_list].present?
        producer = Kafka::Producer.new(producer_options)
        producer.connect()
      else
        producer = nil
      end
      @producer = producer
    end
  end
end

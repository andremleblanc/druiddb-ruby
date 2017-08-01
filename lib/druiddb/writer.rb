#TODO: Seems to be a delay after shutting down Kafka and ZK updating
module DruidDB
  class Writer
    attr_reader :config, :producer, :zk
    def initialize(config, zk)
      @config = config
      @zk = zk
      init_producer
      zk.register_listener(self, :handle_kafka_state_change)
    end

    def write_point(datasource, datapoint)
      raise Druid::ConnectionError, 'no kafka brokers available' if producer.nil?
      producer.produce(datapoint, topic: datasource)
    end

    private

    def broker_list
      zk.registry["/brokers/ids"].map{|instance| "#{instance[:host]}:#{instance[:port]}" }.join(',')
    end

    def handle_kafka_state_change(service)
      if service == config.kafka_broker_path
        producer.shutdown
        init_producer
      end
    end

    def init_producer
      producer_options = {
        seed_brokers: broker_list,
        client_id: config.client_id
      }

      if broker_list.present?
        kafka = Kafka.new(producer_options)
        producer = kafka.async_producer(delivery_threshold: 100, delivery_interval: 10)
        producer.deliver_messages
      else
        producer = nil
      end

      @producer = producer
    end
  end
end

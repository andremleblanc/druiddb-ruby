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
      raise DruidDB::ConnectionError, 'no kafka brokers available' if producer.nil?
      begin
        producer.produce(datapoint.to_json, topic: datasource)
      rescue Kafka::BufferOverflow
        sleep config.kafka_overflow_wait
        retry
      end
    end

    private

    def broker_list
      zk.registry['/brokers/ids'].map { |instance| broker_name(instance) }.join(',')
    end

    def broker_name(instance)
      "#{instance[:host]}:#{instance[:port]}"
    end

    def handle_kafka_state_change(service)
      return unless service == config.kafka_broker_path
      producer.shutdown
      init_producer
    end

    def init_producer
      producer_options = { seed_brokers: broker_list, client_id: config.client_id }

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

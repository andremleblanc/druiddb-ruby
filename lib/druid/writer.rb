module Druid
  class Writer
    attr_reader :config, :producer, :zk
    def initialize(config, zk)
      @config = config
      @zk = zk
      init_producer
    end


    #TODO: Handle no producers in registry
    def write_point(datasource, datapoint)
      begin
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

    # TODO: New producer when nodes change, listen for changes to registry value
    def init_producer
      producer_options = {:broker_list => broker_list, "serializer.class" => "kafka.serializer.StringEncoder"}
      producer = Kafka::Producer.new(producer_options)
      producer.connect()
      @producer = producer
    end
  end
end

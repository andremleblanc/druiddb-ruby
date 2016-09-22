module Druid
  module Node
    class Broker
      QUERY_PATH = '/druid/v2'.freeze

      attr_reader :config, :zk
      def initialize(config, zk)
        @config = config
        @zk = zk
      end

      #TODO: Would caching connections be beneficial?
      def connection
        broker = zk.registry["#{config.discovery_path}/druid:broker"].first
        raise Druid::ConnectionError, 'no druid brokers available' if broker.nil?
        zk.registry["#{config.discovery_path}/druid:broker"].rotate! # round-robin load balancing
        Druid::Connection.new(host: broker[:host], port: broker[:port])
      end

      def query(query_object)
        begin
          response = connection.post(QUERY_PATH, query_object)
        rescue Druid::ConnectionError => e
          # TODO: This sucks, make it better
          (zk.registry["#{config.discovery_path}/druid:broker"].size - 1).times do
            response = connection.post(QUERY_PATH, query_object)
            break if response.code.to_i == 200
          end
        end
        raise QueryError unless response.code.to_i == 200
        JSON.parse(response.body)
      end
    end
  end
end

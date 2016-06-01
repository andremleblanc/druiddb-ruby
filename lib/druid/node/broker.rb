module Druid
  module Node
    class Broker
      QUERY_PATH = '/druid/v2'.freeze

      attr_reader :connection
      def initialize(config)
        @connection = Druid::Connection.new(config.broker_uri)
      end

      def query(query_object)
        response = connection.post(QUERY_PATH, query_object)
        raise QueryError unless response.code.to_i == 200
        JSON.parse(response.body)
      end
    end
  end
end

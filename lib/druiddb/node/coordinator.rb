module DruidDB
  module Node
    class Coordinator
      DATASOURCES_PATH = '/druid/coordinator/v1/datasources/'.freeze

      attr_reader :config, :zk
      def initialize(config, zk)
        @config = config
        @zk = zk
      end

      # TODO: DRY; copy/paste from broker
      def connection
        coordinator = zk.registry["#{config.discovery_path}/druid:coordinator"].first
        raise DruidDB::ConnectionError, 'no druid coordinators available' if coordinator.nil?
        zk.registry["#{config.discovery_path}/druid:coordinator"].rotate! # round-robin load balancing
        DruidDB::Connection.new(host: coordinator[:host], port: coordinator[:port])
      end

      def datasource_info(datasource_name)
        response = connection.get(DATASOURCES_PATH + datasource_name.to_s, full: true)
        raise ConnectionError, 'Unable to retrieve datasource information.' unless response.code.to_i == 200
        JSON.parse(response.body)
      end

      def disable_datasource(datasource_name)
        # response = connection.delete(DATASOURCES_PATH + datasource_name.to_s)
        # raise ConnectionError, 'Unable to disable datasource' unless response.code.to_i == 200
        # return true if response.code.to_i == 200

        # This is a workaround for https://github.com/druid-io/druid/issues/3154
        disable_segments(datasource_name)
        bounded_wait_for_segments_disable(datasource_name)
        true
      end

      # TODO: This should either be private or moved to datasource
      def datasource_enabled?(datasource_name)
        list_datasources.include? datasource_name
      end

      # TODO: This should either be private or moved to datasource
      def datasource_has_segments?(datasource_name)
        list_segments(datasource_name).any?
      end

      def disable_segment(datasource_name, segment)
        response = connection.delete(DATASOURCES_PATH + datasource_name + '/segments/' + segment)
        raise ConnectionError, "Unable to disable #{segment}" unless response.code.to_i == 200
        true
      end

      # TODO: This should either be private or moved to datasource
      def disable_segments(datasource_name)
        segments = list_segments(datasource_name)
        segments.each{ |segment| disable_segment(datasource_name, segment) }
      end

      def issue_kill_task(datasource_name, interval)
        response = connection.delete(DATASOURCES_PATH + datasource_name + '/intervals/' + interval)
        raise ConnectionError, 'Unable to issue kill task.' unless response.code.to_i == 200
        true
      end

      def list_datasources(url_params = {})
        response = connection.get(DATASOURCES_PATH, url_params)
        JSON.parse(response.body) if response.code.to_i == 200
      end

      def list_segments(datasource_name)
        response = connection.get(DATASOURCES_PATH + datasource_name + '/segments', full: true)
        case response.code.to_i
        when 200
          JSON.parse(response.body).map{ |segment| segment['identifier'] }
        when 204
          []
        else
          raise ConnectionError, "Unable to list segments for #{datasource_name}"
        end
      end

      private

      def bounded_wait_for_disable(datasource_name)
        condition = datasource_enabled?(datasource_name)
        attempts = 0
        max = 10

        while(condition) do
          attempts += 1
          sleep 1
          condition = datasource_enabled?(datasource_name)
          break if attempts >= max
        end

        raise ClientError, 'Datasource should be disabled, but is still enabled.' unless condition
        true
      end

      def bounded_wait_for_segments_disable(datasource_name)
        condition = datasource_has_segments?(datasource_name)
        attempts = 0
        max = 60

        while(condition) do
          attempts += 1
          sleep 1
          condition = datasource_has_segments?(datasource_name)
          break if attempts >= max
        end

        raise ClientError, 'Segments should be disabled, but are still enabled.' if condition
        true
      end
    end
  end
end

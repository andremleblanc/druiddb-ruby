module Druid
  module Query
    module Datasource
      java_import org.apache.zookeeper.ZKUtil

      ZOOKEEPER_BEAMS_PATH = '/tranquility/beams/druid:overlord'.freeze

      delegate :datasource_enabled?,
               :datasource_info,
               :disable_datasource,
               :list_datasources,
               to: :coordinator

      def delete_datasource(datasource_name)
        shutdown_tasks(datasource_name)
        datasource_enabled?(datasource_name) ? disable_datasource(datasource_name) : true
        delete_zookeeper_nodes(datasource_name)
        writer.remove_tranquilizer_for_datasource(datasource_name)
      end

      def delete_datasources
        list_datasources.each{ |datasource_name| delete_datasource(datasource_name) }
      end

      private

      def delete_zookeeper_nodes(datasource_name)
        curator = Druid::Writer::Tranquilizer::Curator.build(config)
        curator.start
        zk = curator.getZookeeperClient.getZooKeeper
        ZKUtil.deleteRecursive(zk, ZOOKEEPER_BEAMS_PATH + "/#{datasource_name}")
      end
    end
  end
end

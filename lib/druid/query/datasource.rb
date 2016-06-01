module Druid
  module Query
    module Datasource
      delegate :datasource_enabled?,
               :datasource_info,
               :disable_datasource,
               :list_datasources,
               to: :coordinator

      def delete_datasource(datasource_name)
        shutdown_tasks(datasource_name)
        datasource_enabled?(datasource_name) ? disable_datasource(datasource_name) : true
      end

      def delete_datasources
        list_datasources.each{ |datasource_name| delete_datasource(datasource_name) }
      end
    end
  end
end

module DruidDB
  module Queries
    module Datasources
      delegate :list_datasources, to: :coordinator
    end
  end
end

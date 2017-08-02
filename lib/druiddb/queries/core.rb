module DruidDB
  module Queries
    module Core
      delegate :write_point, to: :writer

      def query(opts)
        DruidDB::Query.create(opts.merge(broker: broker))
      end
    end
  end
end

module DruidDB
  module Queries
    module Task
      delegate :shutdown_tasks, to: :overlord
    end
  end
end

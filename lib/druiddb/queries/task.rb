module DruidDB
  module Queries
    module Task
      delegate :shutdown_tasks,
               :supervisor_tasks,
               :submit_supervisor_spec,
               to: :overlord
    end
  end
end

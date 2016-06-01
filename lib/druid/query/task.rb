module Druid
  module Query
    module Task
      delegate :shutdown_tasks, to: :overlord
    end
  end
end

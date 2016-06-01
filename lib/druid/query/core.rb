module Druid
  module Query
    module Core
      delegate :query, to: :broker
      delegate :write_point, to: :writer
    end
  end
end

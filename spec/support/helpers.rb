module Helpers
  def wait_for_the_future(future)
    until future.isDefined
      sleep 0.3
    end
    wait_for_point_to_be_queryable
  end

  def wait_for_point_to_be_queryable
    sleep 4
  end
end

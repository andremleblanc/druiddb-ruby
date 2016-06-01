module Druid
  module Writer
    module Tranquilizer
      class Timestamper
        include_package com.metamx.tranquility.typeclass.Timestamper

        def timestamp(theMap)
          org.joda.time.DateTime.new(theMap.get("timestamp"))
        end
      end
    end
  end
end

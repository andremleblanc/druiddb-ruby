module Druid
  module Writer
    module Tranquilizer
      class EventListener
        include Logging
        include_package com.twitter.util.FutureEventListener

        def onSuccess(data)
          # logger.debug data.to_s
        end

        def onFailure(error)
          logger.warn error.to_s
        end
      end
    end
  end
end

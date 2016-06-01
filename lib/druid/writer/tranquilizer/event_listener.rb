module Druid
  module Writer
    module Tranquilizer
      class EventListener
        include_package com.twitter.util.FutureEventListener

        def onSuccess(data)
          # puts "success: #{data.to_s}" #TODO: Log this (trace)
        end

        def onFailure(error)
          puts "failure: #{error.to_s}" #TODO: Log this (debug)
        end
      end
    end
  end
end

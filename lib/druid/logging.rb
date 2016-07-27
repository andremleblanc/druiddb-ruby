module Druid
  module Logging
    def logger
      @@logger ||= Druid::Logger.new
    end
  end
end

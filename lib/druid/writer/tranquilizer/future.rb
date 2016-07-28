module Druid
  module Writer
    module Tranquilizer
      class Future
        AWAIT = com.twitter.util.Awaitable::CanAwait
        WAIT_TIME = 20

        attr_reader :future
        delegate :isDefined, to: :future

        def initialize(future)
          @future = future
        end

        def failure?(wait_time  = WAIT_TIME)
          begin
            future.ready(build_duration(wait_time), AWAIT).isThrow
          rescue Java::ComTwitterUtil::TimeoutException => e
            raise Druid::ConnectionError, 'Future timed out.'
          end
        end

        def success?(wait_time = WAIT_TIME)
          begin
            future.ready(build_duration(wait_time), AWAIT).isReturn
          rescue Java::ComTwitterUtil::TimeoutException => e
            raise Druid::ConnectionError, 'Future timed out.'
          end
        end

        private

        def build_duration(duration)
          com.twitter.util.Duration.fromSeconds(duration)
        end
      end
    end
  end
end

module Druid
  module Writer
    module Tranquilizer
      class Curator
        class << self
          def build(config)
            bounded_retry = org.apache.curator.retry.BoundedExponentialBackoffRetry.new(100, 30000, 29)
            CuratorFrameworkFactory.
              builder.
              connectString(config.curator_host).
              retryPolicy(bounded_retry).
              build
          end
        end
      end
    end
  end
end

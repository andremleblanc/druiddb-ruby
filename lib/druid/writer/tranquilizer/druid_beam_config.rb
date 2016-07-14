# Defaults based on https://github.com/druid-io/tranquility/blob/master/core/src/main/scala/com/metamx/tranquility/druid/DruidBeamConfig.scala
module Druid
  module Writer
    module Tranquilizer
      module DruidBeamConfig
        class << self
          java_import com.metamx.tranquility.druid.DruidBeamConfig
          java_import com.metamx.tranquility.druid.OverlordLocator
          java_import com.metamx.tranquility.druid.TaskLocator

          def build(randomize_task_id)
            firehoseGracePeriod = org.joda.time.Period.new('PT5M')
            firehoseQuietPeriod = org.joda.time.Period.new('PT1M')
            firehoseRetryPeriod = org.joda.time.Period.new('PT1M')
            firehoseChunkSize = 1000
            randomizeTaskId = randomize_task_id
            indexRetryPeriod = org.joda.time.Period.new('PT1M')
            firehoseBufferSize = 100000
            overlordLocator = OverlordLocator.Curator
            taskLocator = TaskLocator.Curator
            overlordPollPeriod = org.joda.time.Period.new('PT20S')

            DruidBeamConfig.new(
              firehoseGracePeriod,
              firehoseQuietPeriod,
              firehoseRetryPeriod,
              firehoseChunkSize,
              randomizeTaskId,
              indexRetryPeriod,
              firehoseBufferSize,
              overlordLocator,
              taskLocator,
              overlordPollPeriod
            )
          end
        end
      end
    end
  end
end

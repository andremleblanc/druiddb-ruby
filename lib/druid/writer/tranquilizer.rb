module Druid
  module Writer
    module Tranquilizer
      class << self
        def ch
          Java::Ch
        end

        def io
          Java::Io
        end
      end
      
      java_import com.google.common.collect.ImmutableList
      java_import com.google.common.collect.ImmutableMap
      java_import ch.qos.logback.classic.Level
      java_import ch.qos.logback.classic.encoder.PatternLayoutEncoder
      java_import ch.qos.logback.core.FileAppender
      java_import com.metamx.tranquility.beam.ClusteredBeamTuning
      java_import io.druid.query.aggregation.LongSumAggregatorFactory
      java_import io.druid.granularity.QueryGranularity
      java_import io.druid.data.input.impl.TimestampSpec
      java_import org.apache.curator.framework.CuratorFrameworkFactory
      java_import org.slf4j.LoggerFactory
      java_import org.slf4j.Logger
      java_import Java::ScalaCollection::JavaConverters

      logger = Druid::Writer::Tranquilizer::LoggerFactory.getLogger(Druid::Writer::Tranquilizer::Logger.ROOT_LOGGER_NAME)
      logger.detachAndStopAllAppenders

      appender = Druid::Writer::Tranquilizer::FileAppender.new
      context = logger.getLoggerContext
      encoder = Druid::Writer::Tranquilizer::PatternLayoutEncoder.new

      encoder.setPattern("%date %level [%thread] %logger{10} [%file:%line] %msg%n")
      encoder.setContext(context)
      encoder.start

      appender.setFile('jruby-druid.log')
      appender.setEncoder(encoder)
      appender.setContext(context)
      appender.start

      logger.addAppender(appender)
      logger.setLevel(Druid::Writer::Tranquilizer::Level::TRACE)
    end
  end
end

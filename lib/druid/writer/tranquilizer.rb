module Druid
  module Writer
    module Tranquilizer
      extend Druid::TopLevelPackages

      java_import com.google.common.collect.ImmutableList
      java_import com.google.common.collect.ImmutableMap
      java_import com.metamx.tranquility.beam.ClusteredBeamTuning
      java_import io.druid.query.aggregation.CountAggregatorFactory
      java_import io.druid.query.aggregation.LongSumAggregatorFactory
      java_import io.druid.granularity.QueryGranularity
      java_import io.druid.data.input.impl.TimestampSpec
      java_import org.apache.curator.framework.CuratorFrameworkFactory
      java_import Java::ScalaCollection::JavaConverters
    end
  end
end

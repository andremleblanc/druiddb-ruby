require 'spec_helper'

describe Druid::Writer::Tranquilizer::Aggregators do
  subject { Druid::Writer::Tranquilizer::Aggregators }
  describe '.build' do
    let(:metrics) { { anvils: 1, count: true } }
    let(:result) { subject.build(metrics) }

    it 'builds an ImmutableList' do
      expect(result).to be_a com.google.common.collect.ImmutableList
      expect(result[0]).to be_a io.druid.query.aggregation.CountAggregatorFactory
      expect(result[1]).to be_a io.druid.query.aggregation.LongSumAggregatorFactory
    end
  end
end

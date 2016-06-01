require 'spec_helper'

describe Druid::Writer::Tranquilizer::Aggregators do
  subject { Druid::Writer::Tranquilizer::Aggregators }
  describe '.build' do
    let(:metrics) { { metric_1: {}, metric_2: {} } }

    it 'builds an ImmutableList' do
      expect(subject.build(metrics)).to be_a com.google.common.collect.ImmutableList
    end
  end
end

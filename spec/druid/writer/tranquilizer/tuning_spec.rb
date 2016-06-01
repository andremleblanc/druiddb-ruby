require 'spec_helper'

describe Druid::Writer::Tranquilizer::Tuning do
  subject { Druid::Writer::Tranquilizer::Tuning }
  let(:config) { Druid::Configuration.new() }

  describe '.build' do
    it 'returns a ClusteredBeamTuning' do
      expect(subject.build(config)).to be_a com.metamx.tranquility.beam.ClusteredBeamTuning
    end
  end
end

require 'spec_helper'

describe Druid::Writer::Tranquilizer::Rollup do
  subject { Druid::Writer::Tranquilizer::Rollup }
  let(:config) { Druid::Configuration.new() }
  let(:datapoint) { Druid::Writer::Tranquilizer::Datapoint.new(datapoint_params) }
  let(:datapoint_params) { { dimensions: dimensions, metrics: metrics } }
  let(:dimensions) { { 'manufacturer' => 'ACME' } }
  let(:metrics) { { 'anvils' => 1 } }

  describe '.build' do
    it 'builds a DruidRollup' do
      expect(subject.build(config, datapoint)).to be_a com.metamx.tranquility.druid.DruidRollup
    end
  end
end

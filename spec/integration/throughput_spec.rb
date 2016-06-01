require 'spec_helper'
WebMock.disable_net_connect!(allow_localhost: true)

describe Druid::Client do
  before { subject.delete_datasources }
  after { subject.delete_datasources }

  subject { Druid::Client.new(config) }
  let(:config) { { tuning_granularity: :minute, tuning_window: 'PT10S' } }
  let(:datasource) { 'throughput_spec' }
  let(:datapoint) { { dimensions: dimensions, metrics: metrics } }
  let(:dimensions) { { manufacturer: 'ACME', owner: 'Wile E. Coyote' } }
  let(:metrics) { { anvils: 1 } }

  describe 'write N points' do
    let(:number) { 10000 }

    it 'is successful' do
      expect{ number.times { subject.write_point(datasource, datapoint) } }.not_to raise_error
    end
  end
end

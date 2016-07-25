require 'spec_helper'
WebMock.disable_net_connect!(allow_localhost: true)

describe Druid::Client do
  describe '.write_point with bad ZooKeeper connection' do
    subject { Druid::Client.new(config) }
    let(:config) { { curator_uri: 'foobar', wait_time: wait_time } }
    let(:datapoint) { { metrics: metrics } }
    let(:datasource) { 'basic_spec' }
    let(:metrics) { { anvils: 1 } }
    let(:wait_time) { 10 }

    it 'raises a Druid::ConnectionError' do
      start_time = Time.now.utc
      expect{ subject.write_point(datasource, datapoint) }.to raise_error Druid::ConnectionError
      end_time = Time.now.utc
      elapsed_time = end_time - start_time
      expect(elapsed_time).to be >= wait_time
      expect(elapsed_time).to be < Druid::Configuration::WAIT_TIME
    end
  end
end

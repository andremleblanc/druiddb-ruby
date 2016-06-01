require 'spec_helper'
WebMock.disable_net_connect!(allow_localhost: true)

describe Druid::Client do
  before do
    subject.delete_datasources
    Timecop.freeze(time)
  end

  after do
    Timecop.return
    subject.delete_datasources
  end

  subject { Druid::Client.new(config) }
  let(:config) {
    {
      rollup_granularity: :minute,
      tuning_granularity: interval,
      tuning_window: 'PT5M'
    }
  }
  let(:datapoint) {
    {
      timestamp: event_time,
      dimensions: dimensions,
      metrics: metrics
    }
  }
  let(:datasource) { "tranquilizer_spec_#{Time.now.min}#{Time.now.sec}" }
  let(:dimensions) { { manufacturer: 'ACME', owner: 'Wile E. Coyote' } }
  let(:event_time) { Time.now.utc }
  let(:interval) { :hour }
  let(:metrics) { { anvils: 1 } }
  let(:next_interval) { time.advance(interval => 1) }
  let(:n) { 10 }
  let(:query_object) {
    {
      queryType: 'timeseries',
      dataSource: datasource,
      granularity: 'day',
      intervals: [Time.now.utc.advance(days: -1).iso8601 + '/' + Time.now.utc.advance(days: 1).iso8601],
      aggregations: [{ type: 'longSum', name: 'anvils', fieldName: 'anvils' }],
    }
  }
  let(:query_results) { subject.query(query_object) }
  let(:time) { Time.now }

  describe 'writing across intervals and query points' do
    it 'is successful' do
      expect{ n.times { subject.write_point(datasource, datapoint) } }.not_to raise_error
      Timecop.freeze(next_interval)
      expect{ n.times { @future = subject.write_point(datasource, datapoint) } }.not_to raise_error
      wait_for_the_future(@future)
      wait_for_point_to_be_queryable
      expect(query_results.size).to eq 1
      expect(query_results[0]['result']['anvils']).to eq n * 2
    end
  end
end

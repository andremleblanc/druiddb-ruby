require 'spec_helper'
WebMock.disable_net_connect!(allow_localhost: true)

describe Druid::Client do
  before { subject.delete_datasources }
  after { subject.delete_datasources }

  subject { Druid::Client.new(config) }
  let(:config) {
    {
      rollup_granularity: :second,
      tuning_granularity: :minute,
      tuning_window: 'PT10S'
    }
  }
  let(:datapoint) { { dimensions: dimensions, metrics: metrics } }
  let(:datasource_a) { 'datasource_a' }
  let(:datasource_b) { 'datasource_b' }
  let(:dimensions) { { manufacturer: 'ACME', owner: 'Wile E. Coyote' } }
  let(:metrics) { { anvils: 1 } }
  let(:n) { 10 }
  let(:query_object_a) {
    {
      queryType: 'timeseries',
      dataSource: datasource_a,
      granularity: 'day',
      intervals: [Time.now.utc.advance(days: -1).iso8601 + '/' + Time.now.utc.advance(days: 1).iso8601],
      aggregations: [{ type: 'longSum', name: 'anvils', fieldName: 'anvils' }],
    }
  }
  let(:query_results_a) { subject.query(query_object_a) }
  let(:query_object_b) {
    {
      queryType: 'timeseries',
      dataSource: datasource_b,
      granularity: 'day',
      intervals: [Time.now.utc.advance(days: -1).iso8601 + '/' + Time.now.utc.advance(days: 1).iso8601],
      aggregations: [{ type: 'longSum', name: 'anvils', fieldName: 'anvils' }],
    }
  }
  let(:query_results_b) { subject.query(query_object_b) }

  describe 'writing to multiple datasources' do
    it 'is successful' do
      expect{ n.times { subject.write_point(datasource_a, datapoint) } }.not_to raise_error
      expect{ n.times { @future = subject.write_point(datasource_b, datapoint) } }.not_to raise_error
      wait_for_the_future(@future)
      wait_for_point_to_be_queryable
      expect(query_results_a[0]['result']['anvils']).to eq n
      expect(query_results_b[0]['result']['anvils']).to eq n
    end
  end
end

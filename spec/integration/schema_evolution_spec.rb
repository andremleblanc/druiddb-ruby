require 'spec_helper'
WebMock.disable_net_connect!(allow_localhost: true)

describe Druid::Client do
  before { subject.delete_datasources }
  after { subject.delete_datasources }

  describe 'schema evolution' do
    subject { Druid::Client.new(config) }
    let(:config) {
      {
        rollup_granularity: :second,
        tuning_granularity: :second,
        tuning_window: 'PT10S'
      }
    }
    let(:datapoint_1) { { dimensions: dimensions_1, metrics: metrics_1 } }
    let(:datapoint_2) { { dimensions: dimensions_2, metrics: metrics_2 } }
    let(:datasource) { 'schema_evolution_spec' }
    let(:dimensions_1) { { manufacturer: 'ACME' } }
    let(:dimensions_2) { { manufacturer: 'ACME', owner: 'Wile E. Coyote' } }
    let(:metrics_1) { { anvils: 1 } }
    let(:metrics_2) { { anvils: 1, dynamite: 3 } }
    let(:query_object) {
      {
        queryType: 'timeseries',
        dataSource: datasource,
        granularity: 'second',
        intervals: [Time.now.utc.advance(days: -1).iso8601 + '/' + Time.now.utc.advance(days: 1).iso8601],
        aggregations: [{ type: 'longSum', name: 'anvils', fieldName: 'anvils' }],
      }
    }
    let(:query_results) { subject.query(query_object) }

    it 'handles writing new schema to in progress interval and subsequent intervals' do
      expect{ subject.write_point(datasource, datapoint_1) }.not_to raise_error
      sleep 1
      expect{ @future = subject.write_point(datasource, datapoint_2) }.not_to raise_error
      wait_for_the_future(@future)
      wait_for_point_to_be_queryable
      expect(query_results.size).to eq 2
    end
  end
end

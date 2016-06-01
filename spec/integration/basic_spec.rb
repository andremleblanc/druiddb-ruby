require 'spec_helper'
WebMock.disable_net_connect!(allow_localhost: true)

describe Druid::Client do
  before { subject.delete_datasources }
  after { subject.delete_datasources }

  describe 'write and query' do
    subject { Druid::Client.new(config) }
    let(:config) {
      {
        rollup_granularity: :second,
        tuning_granularity: :second,
        tuning_window: 'PT10S'
      }
    }
    let(:datapoint) {
      {
        timestamp: event_time,
        dimensions: dimensions,
        metrics: metrics
      }
    }
    let(:datasource) { 'basic_spec' }
    let(:dimensions) { { manufacturer: 'ACME', owner: 'Wile E. Coyote' } }
    let(:event_time) { Time.now.utc }
    let(:metrics) { { anvils: 1 } }
    let(:query_object) {
      {
        queryType: 'timeseries',
        dataSource: datasource,
        granularity: 'minute',
        intervals: [Time.now.utc.advance(days: -1).iso8601 + '/' + Time.now.utc.advance(days: 1).iso8601],
        aggregations: [{ type: 'longSum', name: 'anvils', fieldName: 'anvils' }],
      }
    }
    let(:query_results) { subject.query(query_object) }

    context 'a single point' do
      let(:first_segment) { query_results.first }
      let(:segment_timestamp) { DateTime.parse(first_segment['timestamp']) }
      let(:segment_result) { first_segment['result'] }

      it 'is persisted and has correct data' do
        expect{ @future = subject.write_point(datasource, datapoint) }.not_to raise_error
        wait_for_the_future(@future)
        expect(query_results.size).to eq 1
        expect(segment_timestamp).to eq event_time.beginning_of_minute
        expect(segment_result).to eq metrics.stringify_keys
      end
    end
  end
end

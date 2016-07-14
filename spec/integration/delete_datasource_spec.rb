require 'spec_helper'
WebMock.disable_net_connect!(allow_localhost: true)

describe Druid::Client do
  before { subject.delete_datasources }
  after { subject.delete_datasources }

  describe 'writing points to a previously deleted datasource and interval' do
    let(:config) { { tuning_granularity: :day } }

    let(:datapoint) {
      {
        timestamp: event_time,
        dimensions: dimensions,
        metrics: metrics
      }
    }
    let(:datasource) { "delete_datasource_spec_#{suffix}" }
    let(:suffix) { event_time.hour + event_time.min + event_time.sec }
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
    let(:first_segment) { @query_results.first }
    let(:segment_timestamp) { DateTime.parse(first_segment['timestamp']) }
    let(:segment_result) { first_segment['result'] }

    context 'with strong_delete disabled' do
      subject { Druid::Client.new(new_config) }
      let(:new_config) { config.merge(strong_delete: false) }

      it 'writes point(s), deletes datasource, and fails to write the same point(s) again' do
        expect{ @future = subject.write_point(datasource, datapoint) }.not_to raise_error
        wait_for_the_future(@future)
        @query_results = subject.query(query_object)
        expect(@query_results.size).to eq 1
        expect(segment_timestamp).to eq event_time.beginning_of_minute
        expect(segment_result).to eq metrics.stringify_keys

        expect{ subject.delete_datasource(datasource) }.not_to raise_error
        @query_results = subject.query(query_object)
        expect(@query_results.size).to eq 0

        expect{ @future = subject.write_point(datasource, datapoint) }.not_to raise_error
        wait_for_the_future(@future)
        @query_results = subject.query(query_object)
        expect(@query_results.size).to eq 0
      end
    end

    context 'with strong_delete enabled' do
      subject { Druid::Client.new(new_config) }
      let(:new_config) { config.merge(strong_delete: true) }

      it 'writes point(s), deletes datasource, and writes the same point(s) again' do
        expect{ @future = subject.write_point(datasource, datapoint) }.not_to raise_error
        wait_for_the_future(@future)
        @query_results = subject.query(query_object)
        expect(@query_results.size).to eq 1
        expect(segment_timestamp).to eq event_time.beginning_of_minute
        expect(segment_result).to eq metrics.stringify_keys

        expect{ subject.delete_datasource(datasource) }.not_to raise_error
        @query_results = subject.query(query_object)
        expect(@query_results.size).to eq 0

        expect{ @future = subject.write_point(datasource, datapoint) }.not_to raise_error
        wait_for_the_future(@future)
        @query_results = subject.query(query_object)
        expect(@query_results.size).to eq 1
        expect(segment_timestamp).to eq event_time.beginning_of_minute
        expect(segment_result).to eq metrics.stringify_keys
      end
    end
  end
end

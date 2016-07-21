require 'spec_helper'
WebMock.disable_net_connect!(allow_localhost: true)

describe Druid::Client do
  before { subject.delete_datasources }
  after { subject.delete_datasources }

  subject { Druid::Client.new(config) }
  let(:config) { { tuning_window: 'P7D', strong_delete: true } }

  let(:query_time) { Time.now.utc }
  let(:query_result) { [ interval_1, interval_2 ] }
  let(:formatted_results) { [ filled_0, filled_1, filled_2 ] }

  let(:timestamp_0) { query_time.advance(days: -2).beginning_of_day }
  let(:timestamp_1) { query_time.advance(days: -1).beginning_of_day }
  let(:timestamp_2) { query_time.beginning_of_day }

  let(:fill_value) { 0 }
  let(:owner) { "Wile E. Coyote" }

  let(:filled_0) { { 'timestamp' => timestamp_0.iso8601(3), 'event' => filled_0_result } }
  let(:filled_0_result) { { 'anvils' => fill_value, 'dynamite' => fill_value, 'owner' => owner } }

  let(:datapoint_1) { { timestamp: timestamp_1, dimensions: { 'owner' => owner }, metrics: interval_1_data } }
  let(:interval_1) { { 'version' => 'v1', 'timestamp' => timestamp_1.iso8601(3), 'event' => interval_1_data.merge('dynamite' => 0, 'owner' => owner) } }
  let(:interval_1_data) { { 'anvils' => 100 } }
  let(:filled_1) { { 'version' => 'v1', 'timestamp' => timestamp_1.iso8601(3), 'event' => filled_1_result } }
  let(:filled_1_result) { { 'anvils' => 100, 'dynamite' => fill_value, 'owner' => owner } }

  let(:datapoint_2) { { timestamp: timestamp_2, dimensions: { 'owner' => owner }, metrics: interval_2_data } }
  let(:interval_2) { { 'version' => 'v1', 'timestamp' => timestamp_2.iso8601(3), 'event' => interval_2_data.merge('owner' => owner) } }
  let(:interval_2_data) { { 'anvils' => 100, 'dynamite' => 50 } }
  let(:filled_2) { { 'version' => 'v1', 'timestamp' => timestamp_2.iso8601(3), 'event' => filled_2_result } }
  let(:filled_2_result) { { 'anvils' => 100, 'dynamite' => 50, 'owner' => owner } }

  describe '.query' do
    before do
      subject.write_point('widgets', datapoint_1)
      future = subject.write_point('widgets', datapoint_2)
      wait_for_the_future(future)
    end

    context 'fill_value' do
      context 'when not specified' do
        let(:results) { subject.query(opts) }
        let(:opts) {
          {
            queryType: 'groupBy',
            dimensions: ['owner'],
            dataSource: 'widgets',
            granularity: 'day',
            intervals: [query_time.advance(days: -2).iso8601 + '/' + query_time.iso8601],
            aggregations: [
              { type: 'longSum', name: 'anvils', fieldName: 'anvils' },
              { type: 'longSum', name: 'dynamite', fieldName: 'dynamite' }
            ]
          }
        }

        it 'does not modify query results' do
          expect(results).to eq query_result
        end
      end

      context 'when specified' do
        let(:results) { subject.query(opts) }
        let(:opts) {
          {
            queryType: 'groupBy',
            dimensions: ['owner'],
            dataSource: 'widgets',
            granularity: 'day',
            intervals: [query_time.advance(days: -2).iso8601 + '/' + query_time.iso8601],
            aggregations: [
              { type: 'longSum', name: 'anvils', fieldName: 'anvils' },
              { type: 'longSum', name: 'dynamite', fieldName: 'dynamite' }
            ],
            fill_value: fill_value
          }
        }

        it 'fills empty aggregations and intervals with value' do
          expect(results).to eq formatted_results
        end
      end
    end
  end
end

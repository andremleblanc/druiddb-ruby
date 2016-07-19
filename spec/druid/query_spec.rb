require 'spec_helper'

describe Druid::Query do
  subject { Druid::Query.new(opts) }
  let(:query_time) { Time.now.utc }

  let(:opts) {
    {
      queryType: 'timeseries',
      dataSource: 'widgets',
      granularity: 'day',
      intervals: range,
      aggregations: [
        { type: 'longSum', name: 'anvils', fieldName: 'anvils' },
        { type: 'longSum', name: 'dynamite', fieldName: 'dynamite' }
      ],
      broker: broker,
      fill_value: fill_value
    }
  }

  let(:query_opts) {
    {
      queryType: 'timeseries',
      dataSource: 'widgets',
      granularity: 'day',
      intervals: range,
      aggregations: [
        { type: 'longSum', name: 'anvils', fieldName: 'anvils' },
        { type: 'longSum', name: 'dynamite', fieldName: 'dynamite' }
      ]
    }
  }

  let(:range) { query_time.advance(days: -2).iso8601 + '/' + query_time.iso8601 }

  let(:broker) { double('broker') }
  let(:fill_value) { 0 }

  let(:query_result) { [ interval_1, interval_2 ] }
  let(:formatted_results) { [ filled_0, filled_1, filled_2 ] }

  let(:timestamp_0) { query_time.advance(days: -2).beginning_of_day.iso8601(3) }
  let(:timestamp_1) { query_time.advance(days: -1).beginning_of_day.iso8601(3) }
  let(:timestamp_2) { query_time.beginning_of_day.iso8601(3) }

  let(:filled_0) { { 'timestamp' => timestamp_0, 'event' => filled_0_result } }
  let(:filled_0_result) { { 'anvils' => fill_value, 'dynamite' => fill_value } }

  let(:interval_1) { { 'timestamp' => timestamp_1, 'event' => interval_1_result } }
  let(:interval_1_result) { { 'anvils' => 100 } }
  let(:filled_1) { { 'timestamp' => timestamp_1, 'event' => filled_1_result } }
  let(:filled_1_result) { { 'anvils' => 100, 'dynamite' => fill_value } }

  let(:interval_2) { { 'timestamp' => timestamp_2, 'event' => interval_2_result } }
  let(:interval_2_result) { { 'anvils' => 100, 'dynamite' => 50 } }
  let(:filled_2) { { 'timestamp' => timestamp_2, 'event' => filled_2_result } }
  let(:filled_2_result) { { 'anvils' => 100, 'dynamite' => 50 } }

  describe '#execute' do
    it 'queries Druid and formats result' do
      expect(subject.broker).to receive(:query).with(query_opts).and_return(query_result)
      expect(subject.execute).to eq formatted_results
    end

    context 'for granularity' do
      context 'with fill_value' do
        before do
          expect(subject.broker).to receive(:query).and_return(query_result)
        end

        subject { Druid::Query.new(modified_opts) }
        let(:results) { subject.execute }

        context 'second intervals' do
          let(:range) { query_time.advance(hours: -2).iso8601 + '/' + query_time.iso8601 }
          let(:modified_opts) { opts.merge(granularity: 'minute') }
          let(:intervals) { 2 * 60 + 1 }
          it { expect(results.size).to eq intervals }
        end

        context 'minute intervals' do
          let(:modified_opts) { opts.merge(granularity: 'minute') }
          let(:intervals) { 2 * 24 * 60 + 1 }
          it { expect(results.size).to eq intervals }
        end

        context 'fifteen minute intervals' do
          let(:modified_opts) { opts.merge(granularity: 'fifteen_minute') }
          let(:intervals) { 2 * 24 * 4 + 1 }
          it { expect(results.size).to eq intervals }
        end

        context 'thirty minute intervals' do
          let(:modified_opts) { opts.merge(granularity: 'thirty_minute') }
          let(:intervals) { 2 * 24 * 2 + 1 }
          it { expect(results.size).to eq intervals }
        end

        context 'hour intervals' do
          let(:modified_opts) { opts.merge(granularity: 'hour') }
          let(:intervals) { 2 * 24 + 1 }
          it { expect(results.size).to eq intervals }
        end

        context 'day intervals' do
          let(:modified_opts) { opts.merge(granularity: 'day') }
          let(:intervals) { 2 + 1 }
          it { expect(results.size).to eq intervals }
        end

        context 'week intervals' do
          let(:range) { query_time.advance(weeks: -2).iso8601 + '/' + query_time.iso8601 }
          let(:modified_opts) { opts.merge(granularity: 'week') }
          let(:intervals) { 2 + 1 }
          it { expect(results.size).to eq intervals }
        end

        context 'month intervals' do
          let(:range) { query_time.advance(months: -2).iso8601 + '/' + query_time.iso8601 }
          let(:modified_opts) { opts.merge(granularity: 'month') }
          let(:intervals) { 2 + 1 }
          it { expect(results.size).to eq intervals }
        end

        context 'quarter intervals' do
          let(:range) { query_time.advance(months: -6).iso8601 + '/' + query_time.iso8601 }
          let(:modified_opts) { opts.merge(granularity: 'quarter') }
          let(:intervals) { 2 + 1 }
          it { expect(results.size).to eq intervals }
        end

        context 'year intervals' do
          let(:range) { query_time.advance(years: -2).iso8601 + '/' + query_time.iso8601 }
          let(:modified_opts) { opts.merge(granularity: 'year') }
          let(:intervals) { 2 + 1 }
          it { expect(results.size).to eq intervals }
        end
      end
    end
  end

  describe 'class methods' do
    subject { Druid::Query }
    describe '.create' do
      it 'initializes an object and calls execute' do
        query = double('query_instance')
        expect(subject).to receive(:new).with(opts).and_return(query)
        expect(query).to receive(:execute)
        subject.create(opts)
      end
    end
  end
end

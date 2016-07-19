require 'support/helpers'

RSpec.shared_examples 'for_query_core' do
  describe '#query' do
    let(:opts) {
      {
        queryType: 'timeseries',
        dataSource: 'widgets',
        granularity: 'day',
        intervals: query_time.advance(days: -2).iso8601 + '/' + query_time.iso8601,
        aggregations: [
          { type: 'longSum', name: 'anvils', fieldName: 'anvils' },
          { type: 'longSum', name: 'dynamite', fieldsName: 'dynamite' }
        ]
      }
    }
    let(:query_time) { Time.now.utc }

    it 'creates query' do
      expect(Druid::Query).to receive(:create).with(opts.merge(broker: subject.broker))
      subject.query(opts)
    end
  end

  describe '#write_point' do
    it 'delegates call' do
      expect(subject.writer).to receive(:write_point)
      subject.write_point
    end
  end
end

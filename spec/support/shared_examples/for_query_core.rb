require 'support/helpers'

RSpec.shared_examples 'for_query_core' do
  describe '#query' do
    it 'delegates call' do
      expect(subject.broker).to receive(:query)
      subject.query
    end
  end

  describe '#write_point' do
    it 'delegates call' do
      expect(subject.writer).to receive(:write_point)
      subject.write_point
    end
  end
end

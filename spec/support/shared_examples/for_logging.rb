RSpec.shared_examples 'for_logging' do
  describe '#logger' do
    it 'memoizes an instance of Druid::Logger' do
      expect(Druid::Logger).to receive(:new).once.and_call_original
      expect(subject.logger).to be_a Druid::Logger
      expect(subject.logger).to be_a Druid::Logger
    end
  end
end

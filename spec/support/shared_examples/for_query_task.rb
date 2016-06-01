require 'support/helpers'

RSpec.shared_examples 'for_query_task' do
  describe '#shutdown_tasks' do
    it 'delegates call' do
      expect(subject.overlord).to receive(:shutdown_tasks)
      subject.shutdown_tasks
    end
  end
end

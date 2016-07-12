require 'support/helpers'

RSpec.shared_examples 'for_query_datasource' do
  describe '#datasource_enabled?' do
    it 'delegates call' do
      expect(subject.coordinator).to receive(:datasource_enabled?)
      subject.datasource_enabled?
    end
  end

  describe '#datasource_info' do
    it 'delegates call' do
      expect(subject.coordinator).to receive(:datasource_info)
      subject.datasource_info
    end
  end

  describe '#disable_datasource' do
    it 'delegates call' do
      expect(subject.coordinator).to receive(:disable_datasource)
      subject.disable_datasource
    end
  end

  describe '#list_datasources' do
    it 'delegates call' do
      expect(subject.coordinator).to receive(:list_datasources)
      subject.list_datasources
    end
  end

  describe '#delete_datasource' do
    let(:datasource_name) { 'foo' }

    it 'shutsdown running tasks for datasource and deletes it' do
      expect(subject).to receive(:shutdown_tasks).with(datasource_name)
      expect(subject).to receive(:datasource_enabled?).with(datasource_name).and_return(true)
      expect(subject).to receive(:disable_datasource).with(datasource_name)
      expect(subject).to receive(:delete_zookeeper_nodes).with(datasource_name)
      expect(subject.writer).to receive(:remove_tranquilizer_for_datasource).with(datasource_name)
      subject.delete_datasource(datasource_name)
    end
  end

  describe '#delete_datasources' do
    let(:datasources) { %w(foo bar) }
    let(:datasources_count) { datasources.size }

    it 'shutsdown running tasks for datasource and deletes it' do
      expect(subject).to receive(:list_datasources).and_return(datasources)
      expect(subject).to receive(:delete_datasource).exactly(datasources_count).times
      subject.delete_datasources
    end
  end
end

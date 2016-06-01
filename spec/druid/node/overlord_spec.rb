require 'spec_helper'

describe Druid::Node::Overlord do
  subject { Druid::Node::Overlord.new(config) }
  let(:config) { Druid::Configuration.new }
  let(:datasource_name) { 'baz' }
  let(:indexer_uri) { config.overlord_uri[0...-1] + Druid::Node::Overlord::INDEXER_PATH }
  let(:task_uri) { config.overlord_uri[0...-1] + Druid::Node::Overlord::TASK_PATH  }

  describe '.new' do
    context 'with no params' do
      subject { Druid::Node::Overlord.new() }
      it { expect{subject}.to raise_error ArgumentError }
    end

    context 'with config' do
      it { expect{subject}.not_to raise_error }
    end
  end

  describe '#running_tasks' do
    let(:body) { [ task_1, task_2, task_3 ] }
    let(:task_1) { { 'id' => 'baz_task_1' } }
    let(:task_2) { { 'id' => 'baz_task_2' } }
    let(:task_3) { { 'id' => 'bar_task_3' } }

    context 'when response is 200' do
      context 'and there are running tasks' do
        let(:running_tasks) { body.map{|task| task['id']} }
        let(:running_tasks_for_bar) { running_tasks.select!{ |task| task.include? 'bar' } }

        it 'returns the running tasks' do
          stub_request(:get, indexer_uri + 'runningTasks').to_return(status: 200, body: JSON.generate(body))
          expect(subject.running_tasks).to eq running_tasks
        end

        context 'and datasource_name is specified' do
          it 'returns the running tasks for the datasource' do
            stub_request(:get, indexer_uri + 'runningTasks').to_return(status: 200, body: JSON.generate(body))
            expect(subject.running_tasks('bar')).to eq running_tasks_for_bar
          end
        end
      end

      context 'and there are no running tasks' do
        it 'returns an empty set' do
          stub_request(:get, indexer_uri + 'runningTasks').to_return(status: 200, body: JSON.generate([]))
          expect(subject.running_tasks).to eq []
        end
      end
    end

    context 'when response is not 200' do
      it 'raises a ConnectionError' do
        stub_request(:get, indexer_uri + 'runningTasks').to_return(status: 204, body: JSON.generate(body))
        expect{subject.running_tasks}.to raise_error Druid::ConnectionError
      end
    end
  end

  describe '#shutdown_task' do
    let(:task) { 'task_1' }

    context 'when response is 200' do
      it 'returns true' do
        stub_request(:post, task_uri + task + '/shutdown').to_return(status: 200)
        expect(subject).to receive(:running_tasks).and_return([])
        expect(subject.shutdown_task(task)).to eq true
      end
    end

    context 'when response is not 200' do
      it 'raises a ConnectionError' do
        stub_request(:post, task_uri + task + '/shutdown').to_return(status: 204)
        expect{subject.shutdown_task(task)}.to raise_error Druid::ConnectionError
      end
    end
  end

  describe '#shutdown_tasks' do
    let(:tasks) { %w(task_1 task_2) }

    context 'when datasource name is specified' do
      it 'returns tasks that were shutdown' do
        expect(subject).to receive(:running_tasks).with(datasource_name).and_return(tasks)
        expect(subject).to receive(:shutdown_task).exactly(tasks.size).times.and_return(true)
        expect(subject.shutdown_tasks(datasource_name)).to eq tasks
      end
    end

    context 'when datasource name is not specified' do
      it 'returns tasks that were shutdown' do
        expect(subject).to receive(:running_tasks).and_return(tasks)
        expect(subject).to receive(:shutdown_task).exactly(tasks.size).times.and_return(true)
        expect(subject.shutdown_tasks).to eq tasks
      end
    end
  end
end

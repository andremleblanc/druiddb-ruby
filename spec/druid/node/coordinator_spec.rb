require 'spec_helper'

describe Druid::Node::Coordinator do
  subject { Druid::Node::Coordinator.new(config) }
  let(:body) { {'foo' => 'bar'} }
  let(:config) { Druid::Configuration.new }
  let(:coordinator_path) { config.coordinator_uri[0...-1] + Druid::Node::Coordinator::DATASOURCES_PATH }
  let(:datasource_name) { 'baz' }
  let(:json_body) { JSON.generate(body) }

  describe '.new' do
    context 'with no params' do
      subject { Druid::Node::Coordinator.new() }
      it { expect{subject}.to raise_error ArgumentError }
    end

    context 'with config' do
      it { expect{subject}.not_to raise_error }
    end
  end

  describe '#datasource_info' do
    let(:path) { coordinator_path + datasource_name + '?full=true' }

    context 'when request returns a 200' do
      it 'returns parsed JSON' do
        stub_request(:get, path).to_return(status: 200, body: json_body)
        expect(subject.datasource_info(datasource_name)).to eq body
      end
    end

    context 'when request does not return a 200' do
      it 'raises a ConnectionError' do
        stub_request(:get, path).to_return(status: 204, body: json_body)
        expect{subject.datasource_info(datasource_name)}.to raise_error Druid::ConnectionError
      end
    end
  end

  describe '#disable_datasource' do
    it 'returns true' do
      expect(subject).to receive(:disable_segments).with(datasource_name)
      expect(subject).to receive(:bounded_wait_for_segments_disable).with(datasource_name)
      expect(subject.disable_datasource(datasource_name)).to be true
    end
  end

  describe '#datasource_enabled?' do
    context 'when datasource is enabled' do
      let(:datasource_names) { [datasource_name, 'ds2', 'ds3'] }

      it 'returns true' do
        expect(subject).to receive(:list_datasources).and_return(datasource_names)
        expect(subject.datasource_enabled?(datasource_name)).to be true
      end
    end

    context 'when datasource is disabled' do
      let(:datasource_names) { ['ds2', 'ds3'] }

      it 'returns false' do
        expect(subject).to receive(:list_datasources).and_return(datasource_names)
        expect(subject.datasource_enabled?(datasource_name)).to be false
      end
    end
  end

  describe '#datasource_has_segments?' do
    context 'when the datasource has segments' do
      let(:segments) { %w(segment_1) }

      it 'returns true' do
        expect(subject).to receive(:list_segments).with(datasource_name).and_return(segments)
        expect(subject.datasource_has_segments?(datasource_name)).to be true
      end
    end

    context 'when the datasource does not have segments' do
      let(:segments) { [] }

      it 'returns false' do
        expect(subject).to receive(:list_segments).with(datasource_name).and_return(segments)
        expect(subject.datasource_has_segments?(datasource_name)).to be false
      end
    end
  end

  describe '#disable_segment' do
    let(:path) { coordinator_path + datasource_name + '/segments/' + segment }
    let(:segment) { 'segment_1' }

    context 'when request returns a 200' do
      it 'returns true' do
        stub_request(:delete, path).to_return(status: 200)
        expect(subject.disable_segment(datasource_name, segment)).to be true
      end
    end

    context 'when request does not return a 200' do
      it 'raises a ConnectionError' do
        stub_request(:delete, path).to_return(status: 204)
        expect{subject.disable_segment(datasource_name, segment)}.to raise_error Druid::ConnectionError
      end
    end
  end

  describe '#disable_segments' do
    context 'when datasource has segments' do
      let(:segments) { %w(segment_1 segment_2 segment_3) }

      it 'returns disabled segments' do
        expect(subject).to receive(:list_segments).with(datasource_name).and_return(segments)
        expect(subject).to receive(:disable_segment).exactly(segments.size).times
        expect(subject.disable_segments(datasource_name)).to eq segments
      end
    end

    context 'when datasource does not have segments' do
      let(:segments) { [] }

      it 'returns an empty array' do
        expect(subject).to receive(:list_segments).with(datasource_name).and_return(segments)
        expect(subject).to receive(:disable_segment).exactly(segments.size).times
        expect(subject.disable_segments(datasource_name)).to eq segments
      end
    end
  end

  describe '#issue_kill_task' do
    let(:interval) { 'PT1H' }
    let(:path) { coordinator_path + datasource_name + '/intervals/' + interval }

    context 'when request returns a 200' do
      it 'returns true' do
        stub_request(:delete, path).to_return(status: 200)
        expect(subject.issue_kill_task(datasource_name, interval)).to be true
      end
    end

    context 'when request does not return a 200' do
      it 'raises a ConnectionError' do
        stub_request(:delete, path).to_return(status: 204)
        expect{subject.issue_kill_task(datasource_name, interval)}.to raise_error Druid::ConnectionError
      end
    end
  end

  describe '#list_datasources' do
    context 'when request returns a 200' do
      it 'returns parsed response' do
        stub_request(:get, coordinator_path).to_return(status: 200, body: json_body)
        expect(subject.list_datasources).to eq body
      end
    end

    context 'when request does not return a 200' do
      it 'returns falsy' do
        stub_request(:get, coordinator_path).to_return(status: 204, body: json_body)
        expect(subject.list_datasources).to be_falsy
      end
    end

    context 'with url params' do
      it 'correctly formats the request URL' do
        stub_request(:get, coordinator_path + '?full=true').to_return(status: 200, body: json_body)
        expect(subject.list_datasources(full: true)).to eq body
      end
    end
  end

  describe '#list_segments' do
    let(:mapped_segments) { segments.map{ |segment| segment[:identifier] } }
    let(:path) { coordinator_path + datasource_name + '/segments?full=true' }
    let(:segment_1) { { identifier: 'segment_1' } }
    let(:segment_2) { { identifier: 'segment_2' } }
    let(:segments) { [ segment_1, segment_2 ] }

    context 'when request returns a 200' do
      it 'returns segments' do
        stub_request(:get, path).to_return(status: 200, body: JSON.generate(segments))
        expect(subject.list_segments(datasource_name)).to eq mapped_segments
      end
    end

    context 'when request returns a 204' do
      it 'returns an empty set' do
        stub_request(:get, path).to_return(status: 204, body: JSON.generate(segments))
        expect(subject.list_segments(datasource_name)).to eq []
      end
    end

    context 'when request returns neither a 200 or 204' do
      it 'raises a ConnectionError' do
        stub_request(:get, path).to_return(status: 400, body: JSON.generate(segments))
        expect{subject.list_segments(datasource_name)}.to raise_error Druid::ConnectionError
      end
    end
  end
end

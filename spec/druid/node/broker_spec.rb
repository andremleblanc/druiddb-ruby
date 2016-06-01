require 'spec_helper'

describe Druid::Node::Broker do
  subject { Druid::Node::Broker.new(config) }
  let(:body) { {'foo' => 'bar'} }
  let(:config) { Druid::Configuration.new }
  let(:json_body) { JSON.generate(body) }
  let(:path) { config.broker_uri[0...-1] + Druid::Node::Broker::QUERY_PATH }

  describe '.new' do
    context 'with no params' do
      subject { Druid::Node::Broker.new() }
      it { expect{subject}.to raise_error ArgumentError }
    end

    context 'with config' do
      it { expect{subject}.not_to raise_error }
    end
  end

  describe '#query' do
    it 'returns parsed JSON when successful' do
      stub_request(:post, path).to_return(status: 200, body: json_body)
      expect(subject.query({})).to eq body
    end

    it 'raises error when unsuccessful' do
      stub_request(:post, path).to_return(status: 400, body: json_body)
      expect{subject.query({})}.to raise_error Druid::QueryError
    end
  end
end

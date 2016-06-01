require 'spec_helper'

describe Druid::Writer::Tranquilizer::Base do
  subject { Druid::Writer::Tranquilizer::Base.new(params) }
  let(:config) { Druid::Configuration.new }
  let(:datapoint) { Druid::Writer::Tranquilizer::Datapoint.new(datapoint_params) }
  let(:datapoint_params) { { dimensions: dimensions, metrics: metrics } }
  let(:datasource_name) { 'baz' }
  let(:dimensions) { { 'manufacturer' => 'ACME' } }
  let(:metrics) { { 'anvils' => 1 } }
  let(:params) {{ config: config, datapoint: datapoint, datasource: datasource_name } }

  describe '.new' do
    context 'with no params' do
      subject { Druid::Writer::Tranquilizer::Base.new() }
      it { expect{subject}.to raise_error ArgumentError }
    end

    context 'with config' do
      it { expect{subject}.not_to raise_error }
    end
  end

  describe '#send' do
    it 'returns a future' do
      expect(subject.send(datapoint)).to be_a Java::ComTwitterUtil::Promise::Chained
    end
  end

  describe '#start' do
    it 'starts curator and service' do
      expect(subject.curator).to receive(:start)
      expect(subject.service).to receive(:start)
      subject.start
    end
  end

  describe '#stop' do
    it 'starts curator and service' do
      expect(subject.service).to receive(:flush)
      expect(subject.service).to receive(:stop)
      expect(subject.curator).to receive(:close)
      subject.stop
    end
  end
end

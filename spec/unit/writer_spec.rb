require 'spec_helper'

describe DruidDB::Writer do
  let(:config) { double('MockConfig').as_null_object }
  let(:zk) { double('ZK').as_null_object }
  subject { described_class.new(config, zk) }

  describe '#write_point' do
    let(:datasource) { 'foo' }
    let(:datapoint) { {} }
    let(:mock_producer) { double('MockProducer') }

    context 'when Kafka::BufferOverflow raised' do
      before do
        allow(subject).to receive(:producer).and_return(mock_producer)
        allow(config).to receive(:kafka_overflow_wait).and_return(0)
      end

      it 'catches and retries' do
        expect(mock_producer).to receive(:produce).once.and_raise(Kafka::BufferOverflow)
        expect(mock_producer).to receive(:produce).once
        subject.write_point(datasource, datapoint)
      end
    end
  end
end

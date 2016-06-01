require 'spec_helper'

describe Druid::Writer::Tranquilizer::Datapoint do
  subject { Druid::Writer::Tranquilizer::Datapoint.new(params) }
  let(:dimensions) { { 'owner' => 'Wile E. Coyote' } }
  let(:metrics) { { 'anvils' => 1 } }
  let(:params) { { dimensions: dimensions, metrics: metrics } }
  let(:time) { Time.now.utc }

  describe '.new' do
    context 'with only required params' do
      before { Timecop.freeze(time) }
      after { Timecop.return }

      it 'initializes the datapoint with required and default values' do
        expect(subject.dimensions).to eq dimensions
        expect(subject.metrics).to eq metrics
        expect(subject.timestamp['timestamp']).to eq time.iso8601
      end
    end

    context 'with param specified' do
      context 'timestamp' do
        subject { Druid::Writer::Tranquilizer::Datapoint.new(params.merge(timestamp: time)) }
        it { expect(subject.timestamp['timestamp']).to eq time.iso8601 }
      end
    end
  end
end

require 'spec_helper'

describe Druid::Writer::Tranquilizer::Datapoint do
  subject { Druid::Writer::Tranquilizer::Datapoint.new(params) }
  let(:dimensions) { { 'owner' => 'Wile E. Coyote' } }
  let(:metrics) { { 'anvils' => 1 } }
  let(:required_params) { { metrics: metrics } }
  let(:time) { Time.now.utc }

  describe '.new' do
    context 'with only required params' do
      before { Timecop.freeze(time) }
      after { Timecop.return }

      let(:params) { required_params }

      it 'initializes the datapoint with required and default values' do
        expect(subject.dimensions).to eq Hash.new
        expect(subject.metrics).to eq metrics
        expect(subject.timestamp['timestamp']).to eq time.iso8601
      end
    end

    context 'missing required params' do
      let(:params) { {} }
      it { expect{subject}.to raise_error Druid::ValidationError }
    end

    context 'with required and optional params specified' do
      context 'dimensions' do
        let(:params) { required_params.merge(dimensions: dimensions) }
        it { expect(subject.dimensions).to eq dimensions }
      end

      context 'timestamp' do
        let(:params) { required_params.merge(timestamp: time) }
        it { expect(subject.timestamp['timestamp']).to eq time.iso8601 }
      end
    end
  end
end

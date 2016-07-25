require 'spec_helper'

describe Druid::Configuration do
  describe '.new' do
    context 'with no params' do
      it 'sets default values properly' do
        expect(subject.broker_uri).to eq Druid::Configuration::BROKER_URI
        expect(subject.coordinator_uri).to eq Druid::Configuration::COORDINATOR_URI
        expect(subject.curator_uri).to eq Druid::Configuration::CURATOR_URI
        expect(subject.discovery_path).to eq Druid::Configuration::DISCOVERY_PATH
        expect(subject.index_service).to eq Druid::Configuration::INDEX_SERVICE
        expect(subject.overlord_uri).to eq Druid::Configuration::OVERLORD_URI
        expect(subject.rollup_granularity).to eq Druid::Configuration::ROLLUP_GRANULARITY.to_s.upcase
        expect(subject.strong_delete).to eq Druid::Configuration::STRONG_DELETE
        expect(subject.tuning_granularity).to eq Druid::Configuration::TUNING_GRANULARITY.to_s.upcase
        expect(subject.tuning_window).to eq Druid::Configuration::TUNING_WINDOW
        expect(subject.wait_time).to eq Druid::Configuration::WAIT_TIME
      end
    end

    context 'with params' do
      let(:time_duration) { Faker::Number.number(2) }
      let(:time_window) { Faker::Lorem.characters(4) }
      let(:path) { '/druid/path' }
      let(:uri) { Faker::Internet.url }

      context 'broker_uri' do
        subject { Druid::Configuration.new(broker_uri: uri)}
        it { expect(subject.broker_uri).to eq uri }
      end

      context 'coordinator_uri' do
        subject { Druid::Configuration.new(coordinator_uri: uri)}
        it { expect(subject.coordinator_uri).to eq uri }
      end

      context 'curator_uri' do
        subject { Druid::Configuration.new(curator_uri: uri)}
        it { expect(subject.curator_uri).to eq uri }
      end

      context 'discovery_path' do
        subject { Druid::Configuration.new(discovery_path: path)}
        it { expect(subject.discovery_path).to eq path }
      end

      context 'index_service' do
        subject { Druid::Configuration.new(index_service: path)}
        it { expect(subject.index_service).to eq path }
      end

      context 'overlord_uri' do
        subject { Druid::Configuration.new(overlord_uri: uri)}
        it { expect(subject.overlord_uri).to eq uri }
      end

      context 'rollup_granularity' do
        subject { Druid::Configuration.new(rollup_granularity: :interval)}
        it { expect(subject.rollup_granularity).to eq 'INTERVAL' }
      end

      context 'strong_delete' do
        subject { Druid::Configuration.new(strong_delete: true)}
        it { expect(subject.strong_delete).to eq true }
      end

      context 'tuning_granularity' do
        subject { Druid::Configuration.new(tuning_granularity: :interval)}
        it { expect(subject.tuning_granularity).to eq 'INTERVAL' }
      end

      context 'tuning_window' do
        subject { Druid::Configuration.new(tuning_window: time_window)}
        it { expect(subject.tuning_window).to eq time_window }
      end

      context 'wait_time' do
        subject { Druid::Configuration.new(wait_time: time_duration)}
        it { expect(subject.wait_time).to eq time_duration }
      end
    end
  end
end

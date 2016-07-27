require 'spec_helper'

describe Druid::Logger do
  let(:config) { Druid::Configuration.new(log_level: log_level) }
  let(:log_level) {}

  describe 'ClassMethods' do
    subject { Druid::Logger }

    describe '.new' do
      it 'creates Logger and sets level' do
        expect(Logger).to receive(:new).with(STDOUT)
        subject.new
      end
    end
  end

  describe 'InstanceMethods' do
    subject { Druid::Logger.new }
    let(:message) { Faker::Lorem.sentence }

    describe '#set_level' do
      context 'to :foo' do
        let(:log_level) { :foo }
        it { expect{ subject.set_level(log_level) }.to raise_error NameError }
      end

      context 'to :trace' do
        let(:log_level) { :trace }
        it { expect{ subject.set_level(log_level) }.not_to raise_error }
      end

      context 'to :debug' do
        let(:log_level) { :debug }
        it { expect{ subject.set_level(log_level) }.not_to raise_error }
      end

      context 'to :info' do
        let(:log_level) { :info }
        it { expect{ subject.set_level(log_level) }.not_to raise_error }
      end

      context 'to :warn' do
        let(:log_level) { :warn }
        it { expect{ subject.set_level(log_level) }.not_to raise_error }
      end

      context 'to :error' do
        let(:log_level) { :error }
        it { expect{ subject.set_level(log_level) }.not_to raise_error }
      end

      context 'to :critical' do
        let(:log_level) { :critical }
        it { expect{ subject.set_level(log_level) }.not_to raise_error }
      end

      context 'to :fatal' do
        let(:log_level) { :fatal }
        it { expect{ subject.set_level(log_level) }.not_to raise_error }
      end
    end

    describe '#debug' do
      it 'delegates to logger' do
        expect(subject.logger).to receive(:debug).with(message)
        subject.debug(message)
      end
    end

    describe '#info' do
      it 'delegates to logger' do
        expect(subject.logger).to receive(:info).with(message)
        subject.info(message)
      end
    end

    describe '#warn' do
      it 'delegates to logger' do
        expect(subject.logger).to receive(:warn).with(message)
        subject.warn(message)
      end
    end

    describe '#error' do
      it 'delegates to logger' do
        expect(subject.logger).to receive(:error).with(message)
        subject.error(message)
      end
    end

    describe '#fatal' do
      it 'delegates to logger' do
        expect(subject.logger).to receive(:fatal).with(message)
        subject.fatal(message)
      end
    end

    describe '#unknown' do
      it 'delegates to logger' do
        expect(subject.logger).to receive(:unknown).with(message)
        subject.unknown(message)
      end
    end
  end
end

require 'spec_helper'

describe Druid::Writer::Tranquilizer::Future do
  describe 'InstanceMethods' do
    subject { Druid::Writer::Tranquilizer::Future.new(future) }
    let(:future) { double('future') }
    let(:timeout) { Java::ComTwitterUtil::TimeoutException.new('boom') }

    describe '#isDefined' do
      it 'delegates to future' do
        expect(subject.future).to receive(:isDefined)
        subject.isDefined
      end
    end

    describe '#failure?' do
      context 'with timely response' do
        it 'checks if response threw an exception' do
          expect(subject.future).to receive(:ready).and_return(subject.future)
          expect(subject.future).to receive(:isThrow)
          subject.failure?
        end
      end

      context 'when response is a timeout' do
        it 'raises a Druid::ConnectionError' do
          expect(subject.future).to receive(:ready).and_raise(timeout)
          expect{ subject.failure? }.to raise_error Druid::ConnectionError
        end
      end
    end

    describe '#success?' do
      context 'with timely response' do
        it 'checks if response is a return' do
          expect(subject.future).to receive(:ready).and_return(subject.future)
          expect(subject.future).to receive(:isReturn)
          subject.success?
        end
      end

      context 'when response is a timeout' do
        it 'raises a Druid::ConnectionError' do
          expect(subject.future).to receive(:ready).and_raise(timeout)
          expect{ subject.success? }.to raise_error Druid::ConnectionError
        end
      end
    end
  end
end

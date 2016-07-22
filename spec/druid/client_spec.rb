require 'spec_helper'
require 'support/shared_examples/for_logging'
require 'support/shared_examples/for_query_core'
require 'support/shared_examples/for_query_datasource'
require 'support/shared_examples/for_query_task'

describe Druid::Client do
  subject { Druid::Client.new(config) }
  let(:config) { {} }

  describe 'InstanceMethods' do
    include_examples 'for_logging'
    include_examples 'for_query_core'
    include_examples 'for_query_datasource'
    include_examples 'for_query_task'
  end

  describe 'ClassMethods' do
    subject { Druid::Client }

    describe '.new' do
      let(:logger) { Druid::Logger.new }

      it 'initialize and performs setup' do
        expect_any_instance_of(subject).to receive(:logger).with(no_args).and_return(logger)
        expect(logger).to receive(:set_level).with(Druid::Configuration::LOG_LEVEL)
        subject.new(config)
      end
    end
  end
end

require 'spec_helper'
require 'support/shared_examples/for_query_core'
require 'support/shared_examples/for_query_datasource'
require 'support/shared_examples/for_query_task'

describe Druid::Client do
  subject { Druid::Client.new(config) }
  let(:config) { {} }

  include_examples 'for_query_core'
  include_examples 'for_query_datasource'
  include_examples 'for_query_task'

  describe '.new' do
    it 'can be initialized with no params' do
      expect(subject).to be
    end
  end
end

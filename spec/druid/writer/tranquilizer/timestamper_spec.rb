require 'spec_helper'

describe Druid::Writer::Tranquilizer::Timestamper do
  describe '#timestamp' do
    it { expect(subject).to respond_to(:timestamp) }
  end
end

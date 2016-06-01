require 'spec_helper'

describe Druid::Writer::Tranquilizer::Curator do
  subject { Druid::Writer::Tranquilizer::Curator }
  let(:config) { Druid::Configuration.new() }

  describe '.build' do
    it 'builds CuratorFrameworkFactory' do
      expect(subject.build(config)).to be_a org.apache.curator.framework.CuratorFramework
    end
  end
end

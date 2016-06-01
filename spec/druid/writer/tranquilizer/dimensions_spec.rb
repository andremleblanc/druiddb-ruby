require 'spec_helper'

describe Druid::Writer::Tranquilizer::Dimensions do
  subject { Druid::Writer::Tranquilizer::Dimensions }
  let(:dimensions) { { foo: 'bar', baz: 'bar' } }

  describe '.build' do
    it 'builds a DruidDimensions' do
      expect(subject.build(dimensions)).to be_a com.metamx.tranquility.druid.DruidDimensions
    end
  end
end

require 'spec_helper'
WebMock.disable_net_connect!(allow_localhost: true)

describe Druid::Client do
  before { subject.delete_datasources }
  after { subject.delete_datasources }

  subject { Druid::Client.new(config) }
  let(:config) { { strong_delete: true } }
  let(:datapoint) { { metrics: { anvils: 1 } } }
  let(:wait_time) { 20 }

  it 'gets status for the number of workers available then throws an exception' do
    f1 = subject.write_point('f1', datapoint)
    wait_for_the_future(f1)
    f2 = subject.write_point('f2', datapoint)
    wait_for_the_future(f2)
    f3 = subject.write_point('f3', datapoint)
    wait_for_the_future(f3)
    f4 = subject.write_point('f4', datapoint)

    expect(f1.success?(wait_time)).to be true
    expect(f2.success?(wait_time)).to be true
    expect(f3.success?(wait_time)).to be true
    expect{f4.success?(wait_time)}.to raise_error Druid::ConnectionError
  end
end

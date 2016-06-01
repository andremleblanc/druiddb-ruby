 require 'spec_helper'

describe Druid::Connection do
  subject { Druid::Connection.new(endpoint) }
  let(:encoded_params) { URI.encode_www_form(params) }
  let(:encoded_path) { [path, encoded_params].join("?") }
  let(:endpoint) { Faker::Internet.url }
  let(:http) { Net::HTTP.new(uri.host, uri.port) }
  let(:params) { { foo: 'bar' } }
  let(:path) { endpoint + '/path' }
  let(:uri) { URI.parse(endpoint) }

  describe '.new' do
    context 'with no params' do
      subject { Druid::Connection.new() }
      it { expect{subject}.to raise_error ArgumentError }
    end

    context 'with endpoint' do
      it 'builds an HTTP object' do
        expect(subject.http.address).to eq http.address
        expect(subject.http.port).to eq http.port
      end
    end
  end

  describe '#get' do
    it 'makes an HTTP GET request to the endpoint with params' do
      stub_1 = stub_request(:get, encoded_path)
      subject.get(path, params)
      expect(stub_1).to have_been_requested
    end

    context 'when request raises an error' do
      it 'raises a ConnectionError' do
        stub_request(:get, encoded_path).to_raise(Errno::ECONNREFUSED)
        expect{subject.get(path, params)}.to raise_error Druid::ConnectionError
      end
    end
  end

  describe '#post' do
    it 'makes an HTTP GET request to the endpoint with params' do
      stub_1 = stub_request(:post, path).with(body: params.to_json)
      subject.post(path, params)
      expect(stub_1).to have_been_requested
    end

    context 'when request raises an error' do
      it 'raises a ConnectionError' do
        stub_request(:post, path).with(body: params.to_json).to_raise(Errno::ECONNREFUSED)
        expect{subject.post(path, params)}.to raise_error Druid::ConnectionError
      end
    end
  end

  describe '#put' do
    it 'makes an HTTP GET request to the endpoint with params' do
      stub_1 = stub_request(:put, path).with(body: params.to_json)
      subject.put(path, params)
      expect(stub_1).to have_been_requested
    end

    context 'when request raises an error' do
      it 'raises a ConnectionError' do
        stub_request(:put, path).with(body: params.to_json).to_raise(Errno::ECONNREFUSED)
        expect{subject.put(path, params)}.to raise_error Druid::ConnectionError
      end
    end
  end

  describe '#delete' do
    it 'makes an HTTP GET request to the endpoint with params' do
      stub_1 = stub_request(:delete, path).with(body: params.to_json)
      subject.delete(path, params)
      expect(stub_1).to have_been_requested
    end

    context 'when request raises an error' do
      it 'raises a ConnectionError' do
        stub_request(:delete, path).with(body: params.to_json).to_raise(Errno::ECONNREFUSED)
        expect{subject.delete(path, params)}.to raise_error Druid::ConnectionError
      end
    end
  end
end

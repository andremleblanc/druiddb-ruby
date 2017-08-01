# Based on: http://danknox.github.io/2013/01/27/using-rubys-native-nethttp-library/
require 'net/http'

module DruidDB
  class Connection
    CONTENT_TYPE = 'application/json'.freeze
    VERB_MAP = {
      :get    => ::Net::HTTP::Get,
      :post   => ::Net::HTTP::Post,
      :put    => ::Net::HTTP::Put,
      :delete => ::Net::HTTP::Delete
    }

    attr_reader :http

    def initialize(endpoint)
      if endpoint.is_a? String
        uri = URI.parse(endpoint)
        host, port = uri.host, uri.port
      else
        host, port = endpoint.values_at(:host, :port)
      end

      @http = ::Net::HTTP.new(host, port)
    end

    def get(path, params = {})
      request :get, path, params
    end

    def post(path, params = {})
      request :post, path, params
    end

    def put(path, params = {})
      request :put, path, params
    end

    def delete(path, params = {})
      request :delete, path, params
    end

    private

    def encode_path_params(path, params)
      encoded = URI.encode_www_form(params)
      [path, encoded].join("?")
    end

    def request(method, path, params)
      case method
      when :get
        full_path = encode_path_params(path, params)
        request = VERB_MAP[method].new(full_path)
      else
        request = VERB_MAP[method].new(path)
        request.body = params.to_json
      end

      request.content_type = CONTENT_TYPE
      begin
        response = http.request(request)
      rescue Timeout::Error, *Druid::NET_HTTP_EXCEPTIONS => e
        raise ConnectionError, e.message
      end

      response
    end
  end
end

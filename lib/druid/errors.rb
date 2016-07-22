module Druid
  class Error < StandardError; end
  class ClientError < Error; end
  class ConnectionError < Error; end
  class QueryError < Error; end
  class ValidationError < Error; end

  # Adopted from: https://github.com/lostisland/faraday/blob/master/lib/faraday/adapter/net_http.rb
  NET_HTTP_EXCEPTIONS = [
    EOFError,
    Errno::ECONNABORTED,
    Errno::ECONNREFUSED,
    Errno::ECONNRESET,
    Errno::EHOSTUNREACH,
    Errno::EINVAL,
    Errno::ENETUNREACH,
    Net::HTTPBadResponse,
    Net::HTTPHeaderSyntaxError,
    Net::ProtocolError,
    SocketError
  ]
end

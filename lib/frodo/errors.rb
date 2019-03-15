module Frodo
  # Base class for Frodo errors
  class Error < StandardError
  end

  # Base class for network errors
  class RequestError < Error
    attr_reader :response

    def initialize(response, message = nil)
      super(message)
      @message  = message
      @response = response
    end

    def http_status
      response.status
    end

    def message
      [default_message, @message].compact.join(': ')
    end

    def default_message
      nil
    end
  end

  class ClientError < RequestError
  end

  class ServerError < RequestError
  end

  module Errors
    ERROR_MAP = []

    CLIENT_ERRORS = {
      400 => "Bad Request",
      401 => "Access Denied",
      403 => "Forbidden",
      404 => "Not Found",
      405 => "Method Not Allowed",
      406 => "Not Acceptable",
      413 => "Request Entity Too Large",
      415 => "Unsupported Media Type"
    }

    CLIENT_ERRORS.each do |code, message|
      klass = Class.new(ClientError) do
        send(:define_method, :default_message) { "#{code} #{message}" }
      end
      const_set(message.delete(' \-\''), klass)
      ERROR_MAP[code] = klass
    end

    SERVER_ERRORS = {
      500 => "Internal Server Error",
      503 => "Service Unavailable"
    }

    SERVER_ERRORS.each do |code, message|
      klass = Class.new(ServerError) do
        send(:define_method, :default_message) { "#{code} #{message}" }
      end
      const_set(message.delete(' \-\''), klass)
      ERROR_MAP[code] = klass
    end
  end
end

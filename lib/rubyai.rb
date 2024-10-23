require 'faraday'
require 'faraday/net_http_persistent'
require 'json'

require_relative "rubyai/client"
require_relative "rubyai/configuration"
require_relative "rubyai/http"
require_relative "rubyai/version"

module RubyAI
  class Error < StandardError; end
end

require_relative "rubyai/client"
require_relative "rubyai/configuration"
require_relative "rubyai/http"
require_relative "rubyai/version"

require 'faraday'

module RubyAI
  class Error < StandardError; end
end

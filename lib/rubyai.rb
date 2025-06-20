require "faraday"
require "faraday/net_http_persistent"
require "json"

require_relative "rubyai/providers/providers_configuration"
require_relative "rubyai/providers/openai"
require_relative "rubyai/providers/anthropic"
require_relative "rubyai/providers/gemini"
require_relative "rubyai/provider"
require_relative "rubyai/configuration"
require_relative "rubyai/http"
require_relative "rubyai/client"
require_relative "rubyai/chat"
require_relative "rubyai/version"

module RubyAI
  class Error < StandardError; end

  def self.models
    config.models
  end

  def self.configure
    yield config
  end

  def self.config(config = {})
    @config ||= Configuration.new(config)
  end
end

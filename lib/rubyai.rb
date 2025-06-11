require 'faraday'
require 'faraday/net_http_persistent'
require 'json'

require_relative "rubyai/client"
require_relative "rubyai/configuration"
require_relative "rubyai/http"
require_relative "rubyai/version"

module RubyAI
  class Error < StandardError; end

  def self.models 
    Configuration::MODELS.keys
  end

  def self.chat(config_hash = {})
    Client.new(config_hash).call
  end

  def self.configure
    yield(Configuration.new) if block_given?
  end
end

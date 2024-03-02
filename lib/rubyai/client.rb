require 'faraday' 
require 'json' 
require_relative 'configuration' 
require_relative 'http' 
 
module RubyAI 
  class Client 
 
    def initialize(client_or_configuration, messages = nil, **options) 
      if client_or_configuration.is_a?(Configuration) 
        @configuration = client_or_configuration 
      else 
        @configuration = Configuration.new(client_or_configuration, messages, **options) 
      end 
    end 
 
    def call 
      response = connection.post do |req| 
        req.url RubyAI::Configuration::BASE_URL 
        req.headers.merge!(RubyAI::HTTP.build_headers(@configuration.api_key)) 
        req.body = RubyAI::HTTP.build_body(@configuration.messages, @configuration.model, @configuration.temperature).to_json 
      end 
 
      JSON.parse(response.body) 
    end 
 
    private 
 
    def connection 
      @connection ||= Faraday.new do |faraday| 
         faraday.adapter Faraday.default_adapter 
      end 
    end  
  end 
end
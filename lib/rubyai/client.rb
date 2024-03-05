require 'faraday' 
require 'json' 
require_relative 'configuration' 
require_relative 'http' 
 
module RubyAI
  class Client < Configuration
    def initialize(options = {})
      super(options)
      @config = RubyAI.configuration
      apply_options(options)
  end

    def call
      response = connection.post do |req|
        req.url RubyAI::Configuration::BASE_URL
        req.headers.merge!(RubyAI::HTTP.build_headers(@config.api_key))
        req.body = RubyAI::HTTP.build_body(@config.messages, @config.model, @config.temperature).to_json
      end

      JSON.parse(response.body)
    end

    def apply_options(options)
      unless options.empty?
        @config.api_key = options[:api_key]
        @config.messages = options[:messages]
        @model = options.fetch(:model, DEFAULT_MODEL) 
        @temperature = options.fetch(:temperature, 0.7)
      end
    end

    private

    def connection
      @connection ||= Faraday.new do |faraday|
        faraday.adapter Faraday.default_adapter
      end
    end
  end
end

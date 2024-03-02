require 'faraday'
require 'json'
require_relative 'configuration'
require_relative 'http'

module RubyAI
  class Client
    def initialize(api_key, messages, temperature: 0.7, model: RubyAI::Configuration::DEFAULT_MODEL)
      @api_key = api_key
      @messages = messages
      @temperature = temperature
      @model = model
    end

    def call
      response = connection.post do |req|
        req.url RubyAI::Configuration::BASE_URL
        req.headers.merge!(RubyAI::HTTP.build_headers(@api_key))
        req.body = RubyAI::HTTP.build_body(@messages, @model, @temperature).to_json
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

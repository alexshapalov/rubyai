require 'faraday'
require 'json'
require_relative '../configuration'

module RubyAI
  class Client
    def initialize(api_key, messages, temperature: 0.7, model: Configuration::DEFAULT_MODEL)
      @api_key = api_key
      @messages = messages
      @temperature = temperature
      @model = model
    end

    def call
      response = connection.post do |req|
        req.url Configuration::BASE_URL
        req.headers['Content-Type'] = 'application/json'
        req.headers['Authorization'] = "Bearer #{@api_key}"
        req.body = body.to_json
      end

      JSON.parse(response.body)
    end

    private

    def body
      {
        'model': Configuration::MODELS[@model],
        'messages': [{"role": "user", "content": @messages}],
        'temperature': @temperature
      }
    end

    def connection
      @connection ||= Faraday.new do |faraday|
         faraday.adapter Faraday.default_adapter
      end
    end 
  end
end

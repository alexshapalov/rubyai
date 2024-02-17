require 'faraday'
require 'json'

module RubyAI
  class Error < StandardError; end

  class Client
    BASE_URL = "https://api.openai.com/v1/chat/completions"

    def initialize(api_key, messages, temperature: 0.7, model: "gpt-3.5-turbo")
      @api_key = api_key
      @messages = messages
      @temperature = temperature
      @model = model
    end

    attr_accessor :api_key, :model, :messages, :temperature

    def call
      response = connection.post do |req|
        req.url BASE_URL
        req.headers['Content-Type'] = 'application/json'
        req.headers['Authorization'] = "Bearer #{@api_key}"
        req.body = body.to_json
      end

      JSON.parse(response.body)
    end

    private

    def body
      {
        'model': @model,
        'messages': [{"role": "user", "content": @messages}],
        'temperature': @temperature
      }
    end

    def connection
      Faraday.new do |faraday|
        faraday.adapter Faraday.default_adapter
      end
    end
  end
end

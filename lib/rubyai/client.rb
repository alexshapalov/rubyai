require 'faraday'
require 'json'

module RubyAI
  class Client
    BASE_URL = "https://api.openai.com/v1/chat/completions"

    MODELS = {
      "gpt-4" => "gpt-4",
      "gpt-4-0314" => "gpt-4-0314",
      "gpt-4-32k" => "gpt-4-32k",
      "gpt-3.5-turbo" => "gpt-3.5-turbo",
      "gpt-3.5-turbo-0301" => "gpt-3.5-turbo-0301",
      "text-davinci-003" => "text-davinci-003"
    }

    DEFAULT_MODEL = "gpt-3.5-turbo"

    def initialize(api_key, messages, temperature: 0.7, model: DEFAULT_MODEL)
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

    def mode(model)
      @model = model
    end

    private

    def body
      {
        'model': MODELS[@model],
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
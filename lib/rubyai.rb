require 'uri'
require 'net/http'
require 'json'

module RubyAI
  class Error < StandardError; end

  class Client
    BASE_URL = URI.parse("https://api.openai.com/v1/chat/completions")

    def initialize(api_key, messages, temperature: 0.7, model: "gpt-3.5-turbo")
      @api_key = api_key
      @messages = messages
      @temperature = temperature
      @model = model
    end

    attr_accessor :api_key, :model, :messages, :temperature

    def call
      response = Net::HTTP.start(BASE_URL.host, BASE_URL.port, use_ssl: true) do |http|
        request = Net::HTTP::Post.new(BASE_URL.request_uri, header)
        request.body = body.to_json
        http.request(request)
      end

      JSON.parse(response.body)
    end

    private

    def body
      {
        'model': model,
        'messages': [{"role": "user", "content": messages}],
        'temperature': temperature
      }
    end

    def header
      {
        'Content-Type': 'application/json',
        'Authorization': "Bearer #{api_key}"
      }
    end
  end
end

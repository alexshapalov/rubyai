module RubyAI
  module Providers
    class Gemini
      include ProvidersConfiguration


      attr_accessor :api, :messages, :temperature, :max_tokens, :model

       # todo: make an initialization for separate instances for using multiple of them 
      def initialize(api: nil, messages: nil, temperature: 0.7, max_tokens: 1000)
        @api = api
        @messages = messages
        @temperature = temperature
        @max_tokens = max_tokens
      end

      def self.models
        {
          "gemini-1.5-pro" => "gemini-1.5-pro",
          "gemini-1.5-flash" => "gemini-1.5-flash",
          "gemini-1.0-pro" => "gemini-1.0-pro"
        }
      end

      def self.build_http_body(messages = nil, model, temperature)
        {
          contents: [
            {
              parts: [
                {
                  text: messages || @messages
                }
              ]
            }
          ],
          generationConfig: {
            temperature: temperature || @temperature,
            maxOutputTokens: @max_tokens,
            topP: 0.8,
            topK: 10
          }
        }
      end

      def self.build_http_headers(_provider)
        {
          "Content-Type" => "application/json"
        }
      end
    end
  end
end

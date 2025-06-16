module RubyAI
  module Providers
    class Gemini
      extend RubyAI::Providers::ProviderConfiguration

      attr_accessor :api, :messages, :temperature, :max_tokens

      def initialize(api:, messages: nil, temperature: 0.7, max_tokens: 1000)
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

      def self.build_http_body(messages, temperature = 0.7)
        {
          contents: [
            {
              parts: [
                {
                  text: messages
                }
              ]
            }
          ],
          generationConfig: {
            temperature: temperature,
            maxOutputTokens: max_tokens,
            topP: 0.8,
            topK: 10
          }
        }
      end

      def self.build_http_headers(_provider, _config)
        {
          "Content-Type" => "application/json"
        }
      end
    end
  end
end

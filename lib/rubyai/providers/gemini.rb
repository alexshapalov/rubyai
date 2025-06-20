module RubyAI
  module Providers
    class Gemini
      include ProvidersConfiguration

      attr_accessor :api, :messages, :temperature, :max_tokens, :model

      # TODO: make an initialization for separate instances for using multiple of them
      def initialize(api: nil, messages: nil, temperature: 0.7, max_tokens: 1000)
        @api = api
        @messages = messages
        @temperature = temperature
        @max_tokens = max_tokens
      end

      def models
        {
          "gemini-1.5-pro" => "gemini-1.5-pro",
          "gemini-1.5-flash" => "gemini-1.5-flash",
          "gemini-1.0-pro" => "gemini-1.0-pro"
        }
      end

      def build_http_body(messages = nil, _model, temperature, max_tokens: 1000)
        {
          contents: [
            {
              role: "user",
              parts: [
                {
                  text: messages || @messages
                }
              ]
            }
          ],
          generationConfig: {
            temperature: temperature || @temperature,
            maxOutputTokens: @max_tokens || max_tokens,
            topP: 0.8,
            topK: 10
          }
        }
      end

      def build_http_headers(_provider)
        {
          "Content-Type" => "application/json"
        }
      end
    end
  end
end

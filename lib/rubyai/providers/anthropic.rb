module RubyAI
  module Providers
    # doesn't tested yet because i don't have an anthropic api key
    class Anthropic
      extend RubyAI::Providers::ProviderConfiguration

      attr_accessor :api, :messages, :temperature

      def initialize(api:, messages: nil, temperature: 0.7)
        @api = api
        @messages = messages
        @temperature = temperature
      end

      def self.models
        {
          "claude-2" => "claude-2",
          "claude-instant-100k" => "claude-instant-100k",
          "claude-1" => "claude-1",
          "claude-1.3" => "claude-1.3",
          "claude-1.3-sonnet" => "claude-1.3-sonnet",
          "claude-1.3-sonnet-100k" => "claude-1.3-sonnet-100k"
        }.freeze
      end
    end

    def self.build_http_body(messages, model, temperature = 0.7)
      {
        "model" => Configuration::MODELS[provider][model],
        "max_tokens" => 1024, # Required parameter for Anthropic API
        "messages" => format_messages_for_antropic(messages),
        "temperature" => temperature
      }
    end

    def self.build_http_headers(_provider, config)
      {
        "x-api-key" => config.anthropic_api_key,
        "anthropic-version" => "2023-06-01"
      }
    end

    private

    def format_messages_for_antropic(messages)
      # Messages should be an array of message objects
      # Each message needs 'role' (either 'user' or 'assistant') and 'content'
      if messages.is_a?(String)
        [{ "role" => "user", "content" => messages }]
      else
        messages
      end
    end
  end
end

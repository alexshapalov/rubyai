module RubyAI
  module Providers
    # doesn't tested yet because i don't have an anthropic api key
    class Anthropic
      include ProvidersConfiguration

      attr_accessor :api, :messages, :temperature, :max_tokens

      # todo: make an initialization for separate instances for using multiple of them
      def initialize(api: nil, messages: nil, temperature: 0.7, model: "claude-2")
        @api = api
        @messages = messages
        @temperature = temperature
        @model = model 
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

      def self.build_http_body(messages = nil, model = nil, temperature = nil)
        {
          "model" => Configuration::MODELS["anthropic"][model || @model],
          "max_tokens" => 1024, # Required parameter for Anthropic API
          "messages" => format_messages_for_antropic(messages || @messages),
          "temperature" => temperature || @temperature
        }
      end

      def self.build_http_headers(_provider)
        {
          "x-api-key" => RubyAI.configuration.anthropic.api,
          "anthropic-version" => "2023-06-01"
        }
      end

      private

      def self.format_messages_for_antropic(messages)
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
end

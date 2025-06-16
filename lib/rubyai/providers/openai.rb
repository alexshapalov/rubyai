module RubyAI
  module Providers
    class OpenAI
      extend RubyAI::Providers::ProviderConfiguration

      attr_accessor :api, :messages, :temperature

      def initialize(api:, messages: nil, temperature: 0.7)
        @api = api
        @messages = messages
        @temperature = temperature
      end

      DEFAULT_MODEL = "gpt-3.5-turbo".freeze

      def self.models
        {
          "gpt-3.5-turbo" => "gpt-3.5-turbo",
          "gpt-4" => "gpt-4",
          "gpt-4-32k" => "gpt-4-32k",
          "gpt-4-turbo" => "gpt-4-turbo",
          "gpt-4o-mini" => "gpt-4o-mini",
          "o1-mini" => "o1-mini",
          "o1-preview" => "o1-preview",
          "text-davinci-003" => "text-davinci-003"
        }
      end

      def self.build_http_body(messages, model, temperature = 0.7)
        {
          model: Configuration::MODELS["openai"][model] || DEFAULT_MODEL,
          messages: [{ role: "user", content: messages }],
          temperature: temperature
        }
      end

      def self.build_http_headers(_provider, _config)
        {
          "Content-Type": "application/json",
          Authorization: "Bearer #{api}"
        }
      end
    end
  end
end

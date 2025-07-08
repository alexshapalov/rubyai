module RubyAI
  module Providers
    class OpenAI < Base
      attr_accessor :api, :messages, :temperature, :model

      def initialize(api: nil, messages: nil, temperature: 0.7)
        @api = api
        @messages = messages
        @temperature = temperature
      end

      def models
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

      def build_http_body(messages = nil, model = "gpt-3.5-turbo", temperature = nil)
        {
          model: RubyAI::Provider.models["openai"][model],
          messages: [{ role: "user", content: messages || @messages }],
          temperature: temperature || @temperature
        }
      end

      def build_http_headers(_provider)
        {
          Authorization: "Bearer #{@api || RubyAI.config.openai.api}"
        }
      end
    end
  end
end

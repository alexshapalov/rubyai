module RubyAI
  module Providers
    class OpenAI 
      DEFAULT_MODEL = "gpt-3.5-turbo".freeze

      def self.models
        {"gpt-3.5-turbo" => "gpt-3.5-turbo",
        "gpt-4" => "gpt-4",
        "gpt-4-32k" => "gpt-4-32k",
        "gpt-4-turbo" => "gpt-4-turbo",
        "gpt-4o-mini" => "gpt-4o-mini",
        "o1-mini" => "o1-mini",
        "o1-preview" => "o1-preview",
        "text-davinci-003" => "text-davinci-003" }
      end

      # todo: configuration of separate models
    end
  end
end
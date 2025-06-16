module RubyAI
  module Provider
    PROVIDERS = {
      "openai" => RubyAI::Providers::OpenAI,
      # doesn't tested yet because i don't have an anthropic api key
      "anthropic" => RubyAI::Providers::Anthropic,
      'gemini' => RubyAI::Providers::Gemini
    }.freeze

    module_function

    def [](provider)
      PROVIDERS.fetch(provider)
    end
  end
end

module RubyAI
  class Configuration
    # providers config accessors
    attr_accessor :openai,
                  :anthropic,
                  :gemini,
                  # default api config accessors
                  :api,
                  :model,
                  :messages,
                  :temperature,
                  :provider

    PROVIDERS = {
      "openai" => "https://api.openai.com/v1/chat/completions",
      "anthropic" => "https://api.anthropic.com/v1/chat/completions",
      "gemini" => "https://generativelanguage.googleapis.com/v1beta/models"
    }

    def PROVIDERS.[](provider, model = nil)
      return super(provider) unless !model.nil? && provider == "gemini"

      "#{super(provider)}/#{model}:generateContent?key=#{RubyAI.config.gemini.api}"
    end

    def models 
      PROVIDERS.to_h do |provider, _url|
        [provider, send(provider).models]
      end
    end

    def initialize(config = nil)
      @openai ||= Providers::OpenAI.new
      @anthropic ||= Providers::Anthropic.new
      @gemini ||= Providers::Gemini.new
      return if config.nil?
      provider_key = config.fetch(:model, nil).nil? ? "openai" : models.find { |_, models| models.include?(config[:model]) }

      raise ArgumentError, "Unknown model: #{config[:model]}" unless provider_key

      @model = config.fetch(:model, models["openai"]["gpt-3.5-turbo"])
      provider = send(provider_key)
      provider.api = config[:api_key]
      @api_key = provider.api
      provider.messages = config[:messages]
      @messages = provider.messages
      @provider = provider_key
      provider.temperature = config.fetch(:temperature, 0.7)
      @temperature = provider.temperature
    end

    def self.config
      @configuration ||= RubyAI.config({})
    end

    def self.configure
      yield(config)
    end
  end
end

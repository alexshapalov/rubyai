module RubyAI
  class Configuration
    PROVIDERS = {
      "openai" => "https://api.openai.com/v1/chat/completions",
      "anthropic" => "https://api.anthropic.com/v1/chat/completions",
      "gemini" => "https://generativelanguage.googleapis.com/v1beta/models"
    }

    def PROVIDERS.[](provider, model = nil)
      return super(provider) unless !model.nil? && provider == "gemini"
      "#{super(provider)}/#{model}:generateContent?key=#{RubyAI.configuration.gemini.api}"
    end

    MODELS = PROVIDERS.to_h do |provider, _url|
      [provider, Provider[provider].models]
    end.freeze

    BASE_URL = "https://api.openai.com/v1/chat/completions".freeze

    DEFAULT_MODEL = "gpt-3.5-turbo".freeze

    DEFAULT_PROVIDER = "openai".freeze

    # default values for configuration
    attr_accessor :default_provider,
                  :default_provider_api,
                  :default_temperature,
                  :default_model,
                  :openai,
                  :anthropic,
                  :gemini

    def initialize(config = {})
      @default_provider_api = config.fetch(:default_provider_api, nil)
      @default_provider = config.fetch(:default_provider, DEFAULT_PROVIDER)
      @default_temperature = config.fetch(:default_temperature, 0.7)
      @default_model = config.fetch(:default_model, DEFAULT_MODEL)
      @openai ||= Providers::OpenAI.new
      @anthropic ||= Providers::Anthropic.new
      @gemini ||= Providers::Gemini.new
    end
  end

  def self.configuration
    @configuration ||= RubyAI.config({})
  end

  def self.configure
    yield(configuration)
  end
end

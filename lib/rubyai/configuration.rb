module RubyAI
  class Configuration
    PROVIDERS = { 
      'openai' => "https://api.openai.com/v1/chat/completions",
      'anthropic' => "https://api.anthropic.com/v1/chat/completions"
      }.freeze

    MODELS = PROVIDERS.to_h do |provider, _url|
        [provider, Provider[provider].models]
      end.freeze


    BASE_URL = "https://api.openai.com/v1/chat/completions"

    DEFAULT_MODEL = "gpt-3.5-turbo"

    DEFAULT_PROVIDER = 'openai'

    # default values for configuration
    attr_accessor :api_key,
                  :model, 
                  :messages, 
                  :temperature, 
                  :provider,
                  # :providers
                  :anthropic_api_key

    def initialize(config = {})
      @api_key = config.fetch(:api_key, openai_api_key) 
      @openai_api_key = config.fetch(:openai_api_key, api_key) 
      @model = config.fetch(:model, DEFAULT_MODEL)
      @messages = config.fetch(:messages, nil)
      @temperature = config.fetch(:temperature, 0.7)
      @provider = config.fetch(:provider, "openai")
    end
  end

  def self.configuration
    @configuration ||= RubyAI.config(config = {})
  end

  def self.configure
    yield(configuration)
  end
end

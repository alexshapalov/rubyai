module RubyAI
  class Configuration
    PROVIDERS = {
      "openai" => "https://api.openai.com/v1/chat/completions",
      "anthropic" => "https://api.anthropic.com/v1/chat/completions",
      "gemini" => "https://generativelanguage.googleapis.com/v1beta/models"
    }.freeze

    def PROVIDERS.[](provider, model = nil)
      return super(provider) unless !model.nil? && provider == "gemini"

      "#{super(provider)}/#{model}:generateContent?key=#{RubyAI.configuration.gemini.api}"
    end

    MODELS = PROVIDERS.to_h do |provider, _url|
      [provider, Provider[provider].models]
    end.freeze

    # default values for configuration
    attr_accessor :openai,
                  :anthropic,
                  :gemini

    def initialize(_config = {})
      @openai = Providers::OpenAI.new
      @anthropic = Providers::Anthropic.new
      @gemini = Providers::Gemini.new
    end
  end

  def self.configuration
    @configuration ||= RubyAI.config({})
  end

  def self.configure
    yield(configuration)
  end
end

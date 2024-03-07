module RubyAI
  class Configuration
    BASE_URL = "https://api.openai.com/v1/chat/completions"

    MODELS = {
      "gpt-4" => "gpt-4",
      "gpt-4-0314" => "gpt-4-0314",
      "gpt-4-32k" => "gpt-4-32k",
      "gpt-3.5-turbo" => "gpt-3.5-turbo",
      "gpt-3.5-turbo-0301" => "gpt-3.5-turbo-0301",
      "text-davinci-003" => "text-davinci-003"
    }

    DEFAULT_MODEL = "gpt-3.5-turbo"

    attr_accessor :api_key, :model, :messages, :temperature

    def initialize(config = {})
      @api_key = config[:api_key]
      @model = config.fetch(:model, DEFAULT_MODEL)
      @messages = config.fetch(:messages, nil)
      @temperature = config.fetch(:temperature, 0.7)
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
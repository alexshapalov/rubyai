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

    def initialize(config = nil)
      @openai ||= Providers::OpenAI.new
      @anthropic ||= Providers::Anthropic.new
      @gemini ||= Providers::Gemini.new
      return if config.nil? || config.empty?

      provider_key = if config.fetch(:model,
                                     nil).nil?
                       "openai"
                     else
                       Provider.models.find do |_provider, models|
                         models.include?(config[:model])
                       end.first
                     end

      raise ArgumentError, "Unknown model: #{config[:model]}" unless provider_key

      @model = config.fetch(:model, Provider.models["openai"]["gpt-3.5-turbo"])
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
      @config ||= RubyAI.config({})
    end

    def self.configure
      yield(config)
    end
  end
end

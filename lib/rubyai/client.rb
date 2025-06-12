module RubyAI
  class Client
    attr_reader :configuration

    def initialize(config = {})
      @configuration ||= RubyAI.config(config)
    end

    def call
      response = connection.post do |req|
        req.url Configuration::PROVIDERS[configuration.provider] || Configuration::BASE_URL
        req.headers = (HTTP.build_headers(configuration.provider || RubyAI::Configuration::DEFAULT_PROVIDER, RubyAI.config ))
        req.body = HTTP.build_body(configuration.messages, configuration.provider, configuration.model, configuration.temperature).to_json
      end

      JSON.parse(response.body)
    end

    private

    def connection
      @connection ||= Faraday.new do |faraday|
        faraday.adapter Faraday.default_adapter
      end
    end
  end
end

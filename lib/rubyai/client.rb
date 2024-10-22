module RubyAI
  class Client
    attr_reader :configuration

    def initialize(config_hash = {})
      @configuration = Configuration.new(config_hash)
    end

    def call
      response = connection.post do |req|
        req.url Configuration::BASE_URL
        req.headers.merge!(HTTP.build_headers(configuration.api_key))
        req.body = HTTP.build_body(configuration.messages, configuration.model, configuration.temperature).to_json
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

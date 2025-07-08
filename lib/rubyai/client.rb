module RubyAI
  class Client
    attr_accessor :configuration

    def initialize(config = {})
      @configuration = RubyAI.config(config)
    end

    def call
      messages = configuration.messages
      provider = configuration.provider
      model = configuration.model
      temperature = configuration.temperature
      raise ArgumentError, "Messages cannot be empty" if messages.nil? || messages.empty?

      body = HTTP.build_body(messages, provider, model, temperature)
      headers = HTTP.build_headers(provider)

      response = connection.post do |req|
        req.url Provider::PROVIDERS[provider, model]
        req.headers.merge!(headers)
        req.body = body.to_json
      end

      JSON.parse(response.body)
    end

    private

    def connection
      connection ||= Faraday.new do |faraday|
        faraday.adapter Faraday.default_adapter
        faraday.headers["Content-Type"] = "application/json"
      end
    rescue Faraday::Error => e
      raise "Connection error: #{e.message}"
    rescue JSON::ParserError => e
      raise "Response parsing error: #{e.message}"
    rescue StandardError => e
      raise "An unexpected error occurred: #{e.message}"
    end
  end
end

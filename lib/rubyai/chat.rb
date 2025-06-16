module RubyAI
  class Chat
    attr_accessor :provider, :model, :temperature

    def initialize(provider,
                   model: RubyAI.config.default_model, 
                   temperature: RubyAI.config.default_temperature)
      @provider = provider || RubyAI.config.default_provider
      @model = model
      @temperature = temperature
    end

    def call(messages)
      raise ArgumentError, "Messages cannot be empty" if messages.nil? || messages.empty?

      body = HTTP.build_body(messages, @provider, @model, @temperature)
      headers = HTTP.build_headers(provider)

      response = connection.post do |req|
        req.url Configuration::PROVIDERS[@provider, @model]
        req.headers.merge!(headers)
        req.body = body.to_json
      end

      puts response.body.inspect + "\n\n\n\n\n\n\n\n\n"
      JSON.parse(response.body)
    end

    private

    def connection
      @connection ||= Faraday.new do |faraday|
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

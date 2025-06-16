module RubyAI
  module HTTP
    module_function

    def build_body(messages, provider, model, temperature)
      Provider::PROVIDERS.fetch(provider).build_http_body(messages, model, temperature)
    end

    def build_headers(provider, config)
      Provider::PROVIDERS.fetch(provider).build_http_headers(provider, config)
    end
  end
end

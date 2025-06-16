module RubyAI
  module HTTP
    module_function

    def build_body(messages, provider, model, temperature)
      Provider::PROVIDERS.fetch(provider).build_http_body(messages, model, temperature)
    end

    def build_headers(provider)
      Provider::PROVIDERS.fetch(provider).build_http_headers(provider)
    end
  end
end

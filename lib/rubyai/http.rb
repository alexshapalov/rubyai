module RubyAI
  module HTTP
    module_function

    def build_body(messages, provider, model, temperature)
      RubyAI.config.send(provider).build_http_body(messages, model, temperature)
    end

    def build_headers(provider)
      RubyAI.config.send(provider).build_http_headers(provider)
    end
  end
end

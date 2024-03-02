require_relative 'configuration'

module RubyAI
  module HTTP
    module_function

    def build_body(messages, model, temperature)
      {
        'model': RubyAI::Configuration::MODELS[model],
        'messages': [{ "role": "user", "content": messages }],
        'temperature': temperature
      }
    end

    def build_headers(api_key)
      {
        'Content-Type': 'application/json',
        'Authorization': "Bearer #{api_key}"
      }
    end
  end
end
module RubyAI
  module HTTP
    extend self

    def build_body(messages, provider, model, temperature)
      case provider 
      when 'openai'
        {
        'model': Configuration::MODELS[provider][model],
        'messages': [{ "role": "user", "content": messages }],
        'temperature': temperature
        }
      when 'anthropic'
        {
          'model' => Configuration::MODELS[provider][model],
          'max_tokens' => 1024, # Required parameter for Anthropic API
          'messages' => format_messages_for_antropic(messages),
          'temperature' => temperature
        }
      end
    end

    def build_headers(provider, config)
      case provider 
      when 'openai'
        {
        'Content-Type': 'application/json',
        'Authorization': "Bearer #{config.openai_api_key}"
        }
      when 'anthropic'
        {
          'x-api-key' => config.anthropic_api_key,
          'anthropic-version' => '2023-06-01'
        }
      end
    end

    private 

    def format_messages_for_antropic(messages)
      # Messages should be an array of message objects
      # Each message needs 'role' (either 'user' or 'assistant') and 'content'
      if messages.is_a?(String)
        [{ 'role' => 'user', 'content' => messages }]
      else
        messages
      end
    end
  end
end

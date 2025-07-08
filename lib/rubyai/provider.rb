module RubyAI
  module Provider
    module_function
    
    PROVIDERS = {
      "openai" => "https://api.openai.com/v1/chat/completions",
      "anthropic" => "https://api.anthropic.com/v1/chat/completions",
      "gemini" => "https://generativelanguage.googleapis.com/v1beta/models"
    }

    def PROVIDERS.[](provider, model = nil)
      return super(provider) unless !model.nil? && provider == "gemini"

      "#{super(provider)}/#{model}:generateContent?key=#{RubyAI.config.gemini.api}"
    end

    def models 
      PROVIDERS.to_h do |provider, _url|
        [provider, RubyAI.config.send(provider).models]
      end
    end
  end
end

module RubyAI
  module Providers
    module ProvidersConfiguration
      def configure
        yield self
      end
    end
  end
end

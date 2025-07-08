module RubyAI
  module Providers
    class Base
      def configure
        yield self
      end
    end
  end
end
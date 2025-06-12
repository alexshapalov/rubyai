module RubyAI
  module Providers 
    # doesn't tested yet because i don't have an anthropic api key
    class Anthropic
      def self.models = {
        "claude-2" => "claude-2",
        "claude-instant-100k" => "claude-instant-100k",
        "claude-1" => "claude-1",
        "claude-1.3" => "claude-1.3",
        "claude-1.3-sonnet" => "claude-1.3-sonnet",
        "claude-1.3-sonnet-100k" => "claude-1.3-sonnet-100k"
      }.freeze
    end

    # todo: configuration of separate models
  end
end
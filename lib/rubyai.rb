require_relative "rubyai/client"
require_relative "rubyai/configuration"

module RubyAI
  class Error < StandardError; end
end

configuration = RubyAI::Configuration.new("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", "Who is the best chess player in history?")
 client = RubyAI::Client.new(configuration)
 result = client.call
 puts result.dig("choices", 0, "message", "content")
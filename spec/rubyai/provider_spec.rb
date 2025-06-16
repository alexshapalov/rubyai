require "webmock/rspec"
require_relative "../../lib/rubyai/providers/openai"
require_relative "../../lib/rubyai/providers/anthropic"
require_relative "../../lib/rubyai/provider"

RSpec.describe RubyAI::Provider do
  describe "[]" do
    it 'should return the OpenAI provider when "openai" is passed' do
      expect(RubyAI::Provider["openai"]).to eq(RubyAI::Providers::OpenAI)
    end

    it 'should return the Anthropic provider when "anthropic" is passed' do
      expect(RubyAI::Provider["anthropic"]).to eq(RubyAI::Providers::Anthropic)
    end
  end
end

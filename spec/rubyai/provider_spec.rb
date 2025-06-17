require_relative "../../lib/rubyai/providers/providers_configuration"
require_relative "../../lib/rubyai/providers/openai"
require_relative "../../lib/rubyai/providers/anthropic"
require_relative "../../lib/rubyai/providers/gemini"
require_relative "../../lib/rubyai/provider"

require "spec_helper"

RSpec.describe RubyAI::Provider do
  describe "::PROVIDERS" do
    it "includes openai, anthropic and gemini" do
      expect(described_class::PROVIDERS.keys).to include("openai", "anthropic", "gemini")
      expect(described_class::PROVIDERS["openai"]).to eq(RubyAI::Providers::OpenAI)
    end
  end

  describe ".[]" do
    it "returns the corresponding provider class for openai" do
      expect(described_class["openai"]).to eq(RubyAI::Providers::OpenAI)
    end

    it "returns the corresponding provider class for anthropic" do
      expect(described_class["anthropic"]).to eq(RubyAI::Providers::Anthropic)
    end

    it "returns the corresponding provider class for gemini" do
      expect(described_class["gemini"]).to eq(RubyAI::Providers::Gemini)
    end

    it "raises KeyError if provider is unknown" do
      expect { described_class["unknown"] }.to raise_error(KeyError)
    end
  end
end

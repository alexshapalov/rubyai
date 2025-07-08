require_relative "../../lib/rubyai/providers/base"
require_relative "../../lib/rubyai/providers/openai"
require_relative "../../lib/rubyai/providers/anthropic"
require_relative "../../lib/rubyai/providers/gemini"
require_relative "../../lib/rubyai/provider"

require "spec_helper"

RSpec.describe RubyAI::Provider do
  describe "::PROVIDERS" do
    it "returns URL for openai and anthropic without model" do
      expect(described_class::PROVIDERS["openai"]).to eq("https://api.openai.com/v1/chat/completions")
      expect(described_class::PROVIDERS["anthropic"]).to eq("https://api.anthropic.com/v1/chat/completions")
    end

    it "returns extended Gemini URL with model and API key" do
      providers_hash = described_class::PROVIDERS

      # Stub API key
      fake_api_key = "dummy_key"
      allow(RubyAI).to receive_message_chain(:config, :gemini, :api).and_return(fake_api_key)

      gemini_provider = providers_hash["gemini", "gemini-1.5-pro"]
      expect(gemini_provider).to eq(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=#{fake_api_key}"
      )
    end
  end

  describe "::MODELS" do
    before do
      stub_const("RubyAI::Provider::PROVIDERS", {
                   "openai" => "https://openai.test",
                   "gemini" => "https://gemini.test"
                 })

      fake_openai = double("OpenAI", models: { "gpt-test" => "gpt-test" })
      fake_gemini = double("Gemini", models: { "gemini-test" => "gemini-test" })

      allow(RubyAI::Provider.models).to receive(:[]).with("openai").and_return(fake_openai)
      allow(RubyAI::Provider.models).to receive(:[]).with("gemini").and_return(fake_gemini)

      # Reload MODELS constant
      stub_const("RubyAI::Provider::MODELS", {
                   "openai" => fake_openai.models,
                   "gemini" => fake_gemini.models
                 })
    end

    it "returns correct models hash" do
      expect(described_class::MODELS["openai"]).to eq({ "gpt-test" => "gpt-test" })
      expect(described_class::MODELS["gemini"]).to eq({ "gemini-test" => "gemini-test" })
    end
  end
end

require_relative "../../lib/rubyai"
require_relative "../../lib/rubyai/provider"

require "spec_helper"

RSpec.describe RubyAI::Configuration do
  describe "::PROVIDERS" do
    it "returns URL for openai and anthropic without model" do
      expect(described_class::PROVIDERS["openai"]).to eq("https://api.openai.com/v1/chat/completions")
      expect(described_class::PROVIDERS["anthropic"]).to eq("https://api.anthropic.com/v1/chat/completions")
    end

    it "returns extended Gemini URL with model and API key" do
      providers_hash = described_class::PROVIDERS

      # Stub API key
      fake_api_key = "dummy_key"
      allow(RubyAI).to receive_message_chain(:configuration, :gemini, :api).and_return(fake_api_key)

      gemini_provider = providers_hash["gemini", "gemini-1.5-pro"]
      expect(gemini_provider).to eq(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=#{fake_api_key}"
      )
    end
  end

  describe "#initialize" do
    let(:config) { described_class.new }

    it "initializes OpenAI provider" do
      expect(config.openai).to be_a(RubyAI::Providers::OpenAI)
    end

    it "initializes Anthropic provider" do
      expect(config.anthropic).to be_a(RubyAI::Providers::Anthropic)
    end

    it "initializes Gemini provider" do
      expect(config.gemini).to be_a(RubyAI::Providers::Gemini)
    end
  end

  describe "::MODELS" do
    before do
      stub_const("RubyAI::Configuration::PROVIDERS", {
                   "openai" => "https://openai.test",
                   "gemini" => "https://gemini.test"
                 })

      fake_openai = double("OpenAI", models: { "gpt-test" => "gpt-test" })
      fake_gemini = double("Gemini", models: { "gemini-test" => "gemini-test" })

      allow(RubyAI::Provider).to receive(:[]).with("openai").and_return(fake_openai)
      allow(RubyAI::Provider).to receive(:[]).with("gemini").and_return(fake_gemini)

      # Reload MODELS constant
      stub_const("RubyAI::Configuration::MODELS", {
                   "openai" => fake_openai.models,
                   "gemini" => fake_gemini.models
                 })
    end

    it "returns correct models hash" do
      expect(described_class::MODELS["openai"]).to eq({ "gpt-test" => "gpt-test" })
      expect(described_class::MODELS["gemini"]).to eq({ "gemini-test" => "gemini-test" })
    end
  end

  describe "RubyAI.configuration" do
    it "returns a singleton configuration object" do
      config1 = RubyAI.configuration
      config2 = RubyAI.configuration
      expect(config1).to be_a(described_class)
      expect(config1).to equal(config2)
    end
  end

  describe "RubyAI.configure" do
    it "yields configuration object for custom setup" do
      RubyAI.configure do |config|
        expect(config).to be_a(described_class)
        config.openai.api = "custom_key"
      end

      expect(RubyAI.configuration.openai.api).to eq("custom_key")
    end
  end
end

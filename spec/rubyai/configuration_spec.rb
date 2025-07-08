require_relative "../../lib/rubyai"
require_relative "../../lib/rubyai/provider"

require "spec_helper"

RSpec.describe RubyAI::Configuration do
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

  describe "RubyAI.configuration" do
    it "returns a singleton configuration object" do
      config1 = RubyAI.config
      config2 = RubyAI.config
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

      expect(RubyAI.config.openai.api).to eq("custom_key")
    end
  end
end

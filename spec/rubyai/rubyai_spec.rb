require_relative "../../lib/rubyai"

require "spec_helper"

RSpec.describe RubyAI do
  describe ".models" do
    it "returns a hash of provider models" do
      models = described_class.models
      expect(models).to be_a(Hash)
      expect(models.keys).to include("openai", "anthropic", "gemini")
      expect(models["openai"]).to be_a(Hash)
    end
  end

  describe ".config" do
    it "returns a Configuration instance" do
      config = described_class.config
      expect(config).to be_a(RubyAI::Configuration)
    end

    it "returns a memoized instance" do
      expect(described_class.config.object_id).to eq(described_class.config.object_id)
    end
  end

  describe ".configure" do
    it "yields the configuration for modification" do
      expect do
        described_class.configure do |config|
          config.openai.temperature = 0.99
        end
      end.not_to raise_error

      expect(described_class.config.openai.temperature).to eq(0.99)
    end
  end

  describe "RubyAI::Error" do
    it "inherits from StandardError" do
      expect(RubyAI::Error.new).to be_a(StandardError)
    end
  end
end

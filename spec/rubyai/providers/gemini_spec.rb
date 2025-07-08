require "spec_helper"
require_relative "../../../lib/rubyai/providers/providers_configuration"
require_relative "../../../lib/rubyai/providers/gemini"

RSpec.describe RubyAI::Providers::Gemini do
  subject(:gemini) do
    described_class.new(api: "fake_api", messages: "Hello", temperature: 0.9, max_tokens: 500)
  end
  let(:instance) { described_class.new }

  describe "#initialize" do
    it "sets instance variables correctly" do
      expect(gemini.api).to eq("fake_api")
      expect(gemini.messages).to eq("Hello")
      expect(gemini.temperature).to eq(0.9)
      expect(gemini.max_tokens).to eq(500)
    end

    it "sets default values if not provided" do
      default_instance = described_class.new
      expect(default_instance.temperature).to eq(0.7)
      expect(default_instance.max_tokens).to eq(1000)
    end
  end

  describe "#models" do
    it "returns a hash of available Gemini models" do
      expect(instance.models).to include(
        "gemini-1.5-pro" => "gemini-1.5-pro",
        "gemini-1.5-flash" => "gemini-1.5-flash",
        "gemini-1.0-pro" => "gemini-1.0-pro"
      )
    end
  end

  describe "#build_http_body" do
    let(:body) { instance.build_http_body("Hi", "gemini-1.5-pro", 0.6) }

    it "builds the correct request body format" do
      expect(body).to include(:contents, :generationConfig)
      expect(body[:contents].first[:parts].first[:text]).to eq("Hi")
      expect(body[:generationConfig][:temperature]).to eq(0.6)
      expect(body[:generationConfig][:topP]).to eq(0.8)
      expect(body[:generationConfig][:topK]).to eq(10)
    end
  end
end

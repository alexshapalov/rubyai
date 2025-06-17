require_relative "../../lib/rubyai/http"

require "spec_helper"

RSpec.describe RubyAI::HTTP do
  let(:provider_class) { class_double("RubyAI::Providers::OpenAI") }

  before do
    stub_const("RubyAI::Provider::PROVIDERS", { "openai" => provider_class })
  end

  describe ".build_body" do
    it "delegates to the correct provider class with params" do
      expect(provider_class).to receive(:build_http_body)
        .with("Hello", "gpt-3.5-turbo", 0.7)
        .and_return({ body: "ok" })

      result = described_class.build_body("Hello", "openai", "gpt-3.5-turbo", 0.7)
      expect(result).to eq({ body: "ok" })
    end
  end

  describe ".build_headers" do
    it "delegates to the correct provider class" do
      expect(provider_class).to receive(:build_http_headers)
        .with("openai")
        .and_return({ header: "ok" })

      result = described_class.build_headers("openai")
      expect(result).to eq({ header: "ok" })
    end
  end
end

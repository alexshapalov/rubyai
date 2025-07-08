require_relative "../../../lib/rubyai"

# spec/ruby_ai/providers/openai_spec.rb

require "spec_helper"

RSpec.describe RubyAI::Providers::OpenAI do
  subject(:openai) do
    described_class.new(api: "test_api", messages: "Hello OpenAI", temperature: 0.8)
  end
  let(:instance) { described_class.new }

  describe "#initialize" do
    it "initializes instance variables correctly" do
      expect(openai.api).to eq("test_api")
      expect(openai.messages).to eq("Hello OpenAI")
      expect(openai.temperature).to eq(0.8)
    end

    it "uses default temperature if none is provided" do
      expect(instance.temperature).to eq(0.7)
    end
  end

  describe "#models" do
    it "returns all available OpenAI models" do
      expect(instance.models).to include(
        "gpt-3.5-turbo" => "gpt-3.5-turbo",
        "gpt-4" => "gpt-4",
        "gpt-4-32k" => "gpt-4-32k",
        "gpt-4-turbo" => "gpt-4-turbo",
        "gpt-4o-mini" => "gpt-4o-mini",
        "o1-mini" => "o1-mini",
        "o1-preview" => "o1-preview",
        "text-davinci-003" => "text-davinci-003"
      )
    end
  end

  describe "#build_http_body" do
    before do
      stub_const("Configuration::MODELS", {
                   "openai" => {
                     "gpt-3.5-turbo" => "gpt-3.5-turbo"
                   }
                 })
    end

    it "builds a correct request body with given params" do
      result = instance.build_http_body("Hi there", "gpt-3.5-turbo", 0.6)
      expect(result[:model]).to eq("gpt-3.5-turbo")
      expect(result[:messages]).to eq([{ role: "user", content: "Hi there" }])
      expect(result[:temperature]).to eq(0.6)
    end
  end

  describe "#build_http_headers" do
    before do
      allow(RubyAI).to receive_message_chain(:config, :openai,
                                             :api).and_return("fallback_token")
    end

    it "returns headers with Authorization using fallback token" do
      headers = instance.build_http_headers("openai")
      expect(headers[:Authorization]).to eq("Bearer fallback_token")
    end
  end
end

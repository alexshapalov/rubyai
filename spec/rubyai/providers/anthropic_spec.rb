require_relative "../../../lib/rubyai"

require "spec_helper"

RSpec.describe RubyAI::Providers::Anthropic do
  subject(:anthropic) do
    described_class.new(api: "test_api", messages: "Hello Claude", temperature: 0.5)
  end

  describe "#initialize" do
    it "initializes instance variables correctly" do
      expect(anthropic.api).to eq("test_api")
      expect(anthropic.messages).to eq("Hello Claude")
      expect(anthropic.temperature).to eq(0.5)
    end

    it "sets default model if not provided" do
      expect(anthropic.instance_variable_get(:@model)).to eq("claude-2")
    end
  end

  describe ".models" do
    it "returns the list of Anthropic models" do
      expect(described_class.models).to include(
        "claude-2" => "claude-2",
        "claude-instant-100k" => "claude-instant-100k",
        "claude-1.3-sonnet-100k" => "claude-1.3-sonnet-100k"
      )
    end
  end

  describe ".build_http_body" do
    before do
      stub_const("Configuration::MODELS", {
                   "anthropic" => {
                     "claude-2" => "claude-2"
                   }
                 })
    end

    it "builds correct body with string message" do
      result = described_class.build_http_body("Hi!", "claude-2", 0.6)

      expect(result["model"]).to eq("claude-2")
      expect(result["max_tokens"]).to eq(1024)
      expect(result["temperature"]).to eq(0.6)
      expect(result["messages"]).to eq([{ "role" => "user", "content" => "Hi!" }])
    end

    it "builds correct body with array of messages" do
      messages = [
        { "role" => "user", "content" => "Hello" },
        { "role" => "assistant", "content" => "Hi!" }
      ]

      result = described_class.build_http_body(messages, "claude-2", 0.5)
      expect(result["messages"]).to eq(messages)
    end
  end

  describe ".build_http_headers" do
    before do
      allow(RubyAI).to receive_message_chain(:configuration, :anthropic,
                                             :api).and_return("real_api_key")
    end

    it "returns correct headers for Anthropic API" do
      headers = described_class.build_http_headers("anthropic")

      expect(headers["x-api-key"]).to eq("real_api_key")
      expect(headers["anthropic-version"]).to eq("2023-06-01")
    end
  end

  describe ".format_messages_for_antropic" do
    it "wraps string in user role message" do
      result = described_class.send(:format_messages_for_antropic, "Hello")
      expect(result).to eq([{ "role" => "user", "content" => "Hello" }])
    end

    it "returns array unchanged if already properly formatted" do
      messages = [{ "role" => "assistant", "content" => "Hi" }]
      result = described_class.send(:format_messages_for_antropic, messages)
      expect(result).to eq(messages)
    end
  end
end

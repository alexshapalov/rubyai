require_relative "../../lib/rubyai/http"

RSpec.describe RubyAI::HTTP do
  let(:config) do
    double("config",
           openai_api_key: "test-openai-key",
           anthropic_api_key: "test-anthropic-key")
  end

  let(:messages) { "Hello, how are you?" }
  let(:temperature) { 0.7 }

  # Mock the Configuration::MODELS constant
  before do
    stub_const("RubyAI::Configuration::MODELS", {
                 "openai" => {
                   "gpt-3.5-turbo" => "gpt-3.5-turbo",
                   "gpt-4" => "gpt-4"
                 },
                 "anthropic" => {
                   "claude-3-sonnet" => "claude-3-sonnet-20240229",
                   "claude-3-haiku" => "claude-3-haiku-20240307"
                 }
               })
  end

  describe ".build_body" do
    context "when provider is openai" do
      let(:provider) { "openai" }
      let(:model) { "gpt-3.5-turbo" }

      it "returns correct body structure for OpenAI" do
        result = described_class.build_body(messages, provider, model, temperature)

        expect(result).to eq({
                               model: "gpt-3.5-turbo",
                               messages: [{ role: "user", content: messages }],
                               temperature: temperature
                             })
      end

      it "uses the correct model mapping from configuration" do
        model = "gpt-4"
        result = described_class.build_body(messages, provider, model, temperature)

        expect(result[:model]).to eq("gpt-4")
      end

      it "includes temperature parameter" do
        custom_temp = 0.9
        result = described_class.build_body(messages, provider, model, custom_temp)

        expect(result[:temperature]).to eq(custom_temp)
      end
    end

    context "when provider is anthropic" do
      let(:provider) { "anthropic" }
      let(:model) { "claude-3-sonnet" }

      it "returns correct body structure for Anthropic" do
        result = described_class.build_body(messages, provider, model, temperature)

        expect(result).to eq({
                               "model" => "claude-3-sonnet-20240229",
                               "max_tokens" => 1024,
                               "messages" => [{ "role" => "user", "content" => messages }],
                               "temperature" => temperature
                             })
      end

      it "uses the correct model mapping from configuration" do
        model = "claude-3-haiku"
        result = described_class.build_body(messages, provider, model, temperature)

        expect(result["model"]).to eq("claude-3-haiku-20240307")
      end

      it "includes required max_tokens parameter" do
        result = described_class.build_body(messages, provider, model, temperature)

        expect(result["max_tokens"]).to eq(1024)
      end

      it "formats messages correctly for single string input" do
        result = described_class.build_body(messages, provider, model, temperature)

        expect(result["messages"]).to eq([{ "role" => "user", "content" => messages }])
      end

      it "passes through array messages without modification" do
        array_messages = [
          { "role" => "user", "content" => "Hello" },
          { "role" => "assistant", "content" => "Hi there!" }
        ]

        result = described_class.build_body(array_messages, provider, model, temperature)

        expect(result["messages"]).to eq(array_messages)
      end
    end

    context "when provider is unsupported" do
      it "returns nil for unsupported provider" do
        result = described_class.build_body(messages, "unsupported", "model", temperature)

        expect(result).to be_nil
      end
    end
  end

  describe ".build_headers" do
    context "when provider is openai" do
      let(:provider) { "openai" }

      it "returns correct headers for OpenAI" do
        result = described_class.build_headers(provider)

        expect(result).to eq({
                               "Content-Type": "application/json",
                               Authorization: "Bearer #{config.openai_api_key}"
                             })
      end

      it "includes the API key in Authorization header" do
        result = described_class.build_headers(provider, config)

        expect(result[:Authorization]).to eq("Bearer test-openai-key")
      end
    end

    context "when provider is anthropic" do
      let(:provider) { "anthropic" }

      it "returns correct headers for Anthropic" do
        result = described_class.build_headers(provider, config)

        expect(result).to eq({
                               "x-api-key" => config.anthropic_api_key,
                               "anthropic-version" => "2023-06-01"
                             })
      end

      it "includes the API key in x-api-key header" do
        result = described_class.build_headers(provider, config)

        expect(result["x-api-key"]).to eq("test-anthropic-key")
      end

      it "includes the correct anthropic-version" do
        result = described_class.build_headers(provider, config)

        expect(result["anthropic-version"]).to eq("2023-06-01")
      end
    end

    context "when provider is unsupported" do
      it "returns nil for unsupported provider" do
        result = described_class.build_headers("unsupported", config)

        expect(result).to be_nil
      end
    end
  end

  describe ".format_messages_for_antropic" do
    context "when messages is a string" do
      it "converts string to proper message format" do
        string_message = "Hello world"
        result = described_class.send(:format_messages_for_antropic, string_message)

        expect(result).to eq([{ "role" => "user", "content" => string_message }])
      end
    end

    context "when messages is already an array" do
      it "returns the array unchanged" do
        array_messages = [
          { "role" => "user", "content" => "Question" },
          { "role" => "assistant", "content" => "Answer" }
        ]

        result = described_class.send(:format_messages_for_antropic, array_messages)

        expect(result).to eq(array_messages)
      end
    end

    context "when messages is empty string" do
      it "handles empty string correctly" do
        result = described_class.send(:format_messages_for_antropic, "")

        expect(result).to eq([{ "role" => "user", "content" => "" }])
      end
    end

    context "when messages is nil" do
      it "returns nil unchanged" do
        result = described_class.send(:format_messages_for_antropic, nil)

        expect(result).to be_nil
      end
    end
  end

  describe "integration scenarios" do
    it "builds complete OpenAI request components" do
      provider = "openai"
      model = "gpt-4"

      body = described_class.build_body(messages, provider, model, temperature)
      headers = described_class.build_headers(provider, config)

      expect(body[:model]).to eq("gpt-4")
      expect(body[:messages]).to be_an(Array)
      expect(headers[:"Content-Type"]).to eq("application/json")
      expect(headers[:Authorization]).to include("Bearer")
    end

    it "builds complete Anthropic request components" do
      provider = "anthropic"
      model = "claude-3-sonnet"

      body = described_class.build_body(messages, provider, model, temperature)
      headers = described_class.build_headers(provider, config)

      expect(body["model"]).to eq("claude-3-sonnet-20240229")
      expect(body["messages"]).to be_an(Array)
      expect(body["max_tokens"]).to eq(1024)
      expect(headers["x-api-key"]).to eq("test-anthropic-key")
      expect(headers["anthropic-version"]).to eq("2023-06-01")
    end
  end
end

require_relative "../../lib/rubyai/http"
require "spec_helper"

RSpec.describe RubyAI::HTTP do
  describe ".build_body" do
    let(:messages) { [{ role: "user", content: "Hello" }] }
    let(:provider) { :openai }
    let(:model) { "gpt-3.5-turbo" }
    let(:temperature) { 0.7 }
    let(:mock_config) { double("config") }
    let(:mock_provider_config) { double("provider_config") }
    let(:expected_body) { { messages: messages, model: model, temperature: temperature } }

    before do
      allow(RubyAI).to receive(:config).and_return(mock_config)
      allow(mock_config).to receive(:send).with(provider).and_return(mock_provider_config)
    end

    context "when provider configuration exists" do
      it "calls build_http_body on the provider configuration" do
        expect(mock_provider_config).to receive(:build_http_body)
          .with(messages, model, temperature)
          .and_return(expected_body)

        result = described_class.build_body(messages, provider, model, temperature)
        expect(result).to eq(expected_body)
      end

      it "passes all parameters correctly" do
        expect(mock_provider_config).to receive(:build_http_body)
          .with(messages, model, temperature)

        described_class.build_body(messages, provider, model, temperature)
      end
    end

    context "with different providers" do
      it "works with anthropic provider" do
        anthropic_provider = :anthropic
        allow(mock_config).to receive(:send).with(anthropic_provider).and_return(mock_provider_config)
        expect(mock_provider_config).to receive(:build_http_body)
          .with(messages, model, temperature)

        described_class.build_body(messages, anthropic_provider, model, temperature)
      end

      it "works with custom provider" do
        custom_provider = :custom
        allow(mock_config).to receive(:send).with(custom_provider).and_return(mock_provider_config)
        expect(mock_provider_config).to receive(:build_http_body)
          .with(messages, model, temperature)

        described_class.build_body(messages, custom_provider, model, temperature)
      end
    end

    context "with different parameter types" do
      it "handles string provider" do
        string_provider = "openai"
        allow(mock_config).to receive(:send).with(string_provider).and_return(mock_provider_config)
        expect(mock_provider_config).to receive(:build_http_body)
          .with(messages, model, temperature)

        described_class.build_body(messages, string_provider, model, temperature)
      end

      it "handles different temperature values" do
        [0.0, 0.5, 1.0, 1.5].each do |temp|
          expect(mock_provider_config).to receive(:build_http_body)
            .with(messages, model, temp)

          described_class.build_body(messages, provider, model, temp)
        end
      end

      it "handles different model types" do
        models = %w[gpt-4 claude-3 llama-2]
        models.each do |test_model|
          expect(mock_provider_config).to receive(:build_http_body)
            .with(messages, test_model, temperature)

          described_class.build_body(messages, provider, test_model, temperature)
        end
      end
    end

    context "when provider configuration raises an error" do
      it "propagates the error from provider configuration" do
        allow(mock_provider_config).to receive(:build_http_body)
          .and_raise(StandardError, "Provider configuration error")

        expect do
          described_class.build_body(messages, provider, model, temperature)
        end.to raise_error(StandardError, "Provider configuration error")
      end
    end
  end

  describe ".build_headers" do
    let(:provider) { :openai }
    let(:mock_config) { double("config") }
    let(:mock_provider_config) { double("provider_config") }
    let(:expected_headers) do
      { "Authorization" => "Bearer token", "Content-Type" => "application/json" }
    end

    before do
      allow(RubyAI).to receive(:config).and_return(mock_config)
      allow(mock_config).to receive(:send).with(provider).and_return(mock_provider_config)
    end

    context "when provider configuration exists" do
      it "calls build_http_headers on the provider configuration" do
        expect(mock_provider_config).to receive(:build_http_headers)
          .with(provider)
          .and_return(expected_headers)

        result = described_class.build_headers(provider)
        expect(result).to eq(expected_headers)
      end

      it "passes the provider parameter correctly" do
        expect(mock_provider_config).to receive(:build_http_headers)
          .with(provider)

        described_class.build_headers(provider)
      end
    end

    context "with different providers" do
      it "works with anthropic provider" do
        anthropic_provider = :anthropic
        allow(mock_config).to receive(:send).with(anthropic_provider).and_return(mock_provider_config)
        expect(mock_provider_config).to receive(:build_http_headers)
          .with(anthropic_provider)

        described_class.build_headers(anthropic_provider)
      end

      it "works with string provider" do
        string_provider = "openai"
        allow(mock_config).to receive(:send).with(string_provider).and_return(mock_provider_config)
        expect(mock_provider_config).to receive(:build_http_headers)
          .with(string_provider)

        described_class.build_headers(string_provider)
      end
    end

    context "when provider configuration raises an error" do
      it "propagates the error from provider configuration" do
        allow(mock_provider_config).to receive(:build_http_headers)
          .and_raise(ArgumentError, "Invalid provider")

        expect do
          described_class.build_headers(provider)
        end.to raise_error(ArgumentError, "Invalid provider")
      end
    end
  end

  describe "module structure" do
    it "is a module" do
      expect(RubyAI::HTTP).to be_a(Module)
    end

    it "extends module_function" do
      expect(RubyAI::HTTP.methods).to include(:build_body, :build_headers)
    end

    it "has the expected public methods" do
      expect(described_class).to respond_to(:build_body)
      expect(described_class).to respond_to(:build_headers)
    end
  end

  describe "integration scenarios" do
    let(:mock_config) { double("config") }
    let(:mock_openai_config) { double("openai_config") }
    let(:mock_anthropic_config) { double("anthropic_config") }

    before do
      allow(RubyAI).to receive(:config).and_return(mock_config)
      allow(mock_config).to receive(:send).with(:openai).and_return(mock_openai_config)
      allow(mock_config).to receive(:send).with(:anthropic).and_return(mock_anthropic_config)
    end

    it "can build body and headers for the same provider" do
      messages = [{ role: "user", content: "Test" }]
      provider = :openai
      model = "gpt-3.5-turbo"
      temperature = 0.8

      expect(mock_openai_config).to receive(:build_http_body)
        .with(messages, model, temperature)
        .and_return({ messages: messages })

      expect(mock_openai_config).to receive(:build_http_headers)
        .with(provider)
        .and_return({ "Authorization" => "Bearer test" })

      body = described_class.build_body(messages, provider, model, temperature)
      headers = described_class.build_headers(provider)

      expect(body).to eq({ messages: messages })
      expect(headers).to eq({ "Authorization" => "Bearer test" })
    end

    it "can handle different providers in the same test" do
      messages = [{ role: "user", content: "Test" }]

      expect(mock_openai_config).to receive(:build_http_body)
        .and_return({ openai: "body" })
      expect(mock_anthropic_config).to receive(:build_http_body)
        .and_return({ anthropic: "body" })

      openai_body = described_class.build_body(messages, :openai, "gpt-4", 0.7)
      anthropic_body = described_class.build_body(messages, :anthropic, "claude-3", 0.5)

      expect(openai_body).to eq({ openai: "body" })
      expect(anthropic_body).to eq({ anthropic: "body" })
    end
  end
end

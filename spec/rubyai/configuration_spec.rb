require "webmock/rspec"
require_relative "../../lib/rubyai/client"
require_relative "../../lib/rubyai/providers/openai"
require_relative "../../lib/rubyai/providers/anthropic"
require_relative "../../lib/rubyai/provider"
require_relative "../../lib/rubyai/configuration"

RSpec.describe RubyAI::Client do
  let(:api_key) { "your_api_key" }
  let(:messages) { "Hello, how are you?" }
  let(:temperature) { 0.7 }
  let(:model) { "gpt-3.5-turbo" }
  let(:provider) { "openai" }

  before do
    RubyAI.configure do |config|
      config.provider = provider
      config.model = model
      config.temperature = temperature
      config.api_key = api_key
      config.messages = messages
    end
  end

  describe "#call" do
    let(:response_body) do
      { "choices" => [{ "message" => { "content" => "This is a response from the model." } }] }
    end
    let(:status) { 200 }

    before do
      stub_request(:post, RubyAI::Configuration::BASE_URL)
        .to_return(status: status, body: response_body.to_json, headers: { "Content-Type" => "application/json" })
    end

    it "returns parsed JSON response when passing through client via configuration" do
      configuration = { api_key: RubyAI.configuration.api_key,
                        messages: RubyAI.configuration.messages }
      client = described_class.new(configuration)
      result = client.call
      expect(result.dig("choices", 0, "message",
                        "content")).to eq("This is a response from the model.")
    end
  end

  describe "Constants" do
    specify "PROVIDERS" do
      expect(RubyAI::Configuration::PROVIDERS).to eq(
        "openai" => "https://api.openai.com/v1/chat/completions",
        "anthropic" => "https://api.anthropic.com/v1/chat/completions"
      )
    end

    specify "MODELS should return Hash" do
      expect(RubyAI::Configuration::MODELS).to be_an_instance_of(Hash)
    end

    specify "BASE_URL" do
      expect(RubyAI::Configuration::BASE_URL).to eq("https://api.openai.com/v1/chat/completions")
    end

    specify "DEFAULT_MODEL" do
      expect(RubyAI::Configuration::DEFAULT_MODEL).to eq("gpt-3.5-turbo")
    end

    specify "DEFAULT_PROVIDER" do
      expect(RubyAI::Configuration::DEFAULT_PROVIDER).to eq("openai")
    end
  end
end

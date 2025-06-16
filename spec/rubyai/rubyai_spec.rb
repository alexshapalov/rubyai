require_relative "../../lib/rubyai"

RSpec.describe RubyAI do
  describe ".models" do
    it "should return available models" do
      expect(RubyAI.models).to eq(RubyAI::Configuration::MODELS)
    end
  end

  describe ".chat" do
    let(:api_key) { "your_api_key" }
    let(:messages) { "Hello, how are you?" }
    let(:temperature) { 0.7 }
    let(:model) { "gpt-3.5-turbo" }
    let(:provider) { "openai" }
    let(:client) do
      described_class.chat(api_key: api_key, messages: messages, temperature: temperature,
                           provider: provider, model: model)
    end

    let(:response_body) { { "completion" => "This is a response from the model." } }
    let(:status) { 200 }

    before do
      stub_request(:post, RubyAI::Configuration::BASE_URL)
        .to_return(status: status, body: response_body.to_json, headers: { "Content-Type" => "application/json" })
    end

    it "returns parsed JSON response when passing through client directly" do
      expect(described_class.chat).to eq(response_body)
    end
  end

  describe ".configure" do
    let(:configuration) { RubyAI.config }

    it "allows configuration of the client" do
      described_class.configure do |config|
        config.api_key = "your_api_key"
        config.messages = "Hello, how are you?"
        config.temperature = 0.7
        config.provider = "openai"
        config.model = "gpt-3.5-turbo"
      end

      expect(configuration.api_key).to eq("your_api_key")
      expect(configuration.messages).to eq("Hello, how are you?")
      expect(configuration.temperature).to eq(0.7)
      expect(configuration.provider).to eq("openai")
      expect(configuration.model).to eq("gpt-3.5-turbo")
    end
  end
end

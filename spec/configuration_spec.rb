require 'webmock/rspec'
require_relative '../lib/rubyai/client.rb'

RSpec.describe RubyAI::Client do
  let(:api_key) { 'your_api_key' }
  let(:messages) { 'Hello, how are you?' }
  let(:temperature) { 0.7 }
  let(:model) { 'gpt-3.5-turbo' }

  before do
    RubyAI.configure do |config|
      config.api_key = api_key
      config.messages = messages
    end
  end

  describe '#call' do
    let(:response_body) { { 'choices' => [{ 'message' => { 'content' => 'This is a response from the model.' } }] } }
    let(:status) { 200 }

    before do
      stub_request(:post, RubyAI::Configuration::BASE_URL)
        .to_return(status: status, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns parsed JSON response when passing through client via configuration' do
      configuration = { api_key: RubyAI.configuration.api_key, messages: RubyAI.configuration.messages }
      client = described_class.new(configuration)
      result = client.call
      expect(result.dig('choices', 0, 'message', 'content')).to eq('This is a response from the model.')
    end
  end
end

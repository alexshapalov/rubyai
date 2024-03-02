require 'webmock/rspec'
require_relative '../lib/rubyai/client.rb'

RSpec.describe RubyAI::Client do
  let(:api_key) { 'your_api_key' }
  let(:messages) { 'Hello, how are you?' }
  let(:temperature) { 0.7 }
  let(:model) { 'gpt-3.5-turbo' }

  describe '#call' do
    let(:response_body) { { 'completion' => 'This is a response from the model.' } }
    let(:status) { 200 }
    let(:configuration) { RubyAI::Configuration.new(api_key, messages, temperature: temperature, model: model) }
    let(:client) { described_class.new(configuration) }

    before do
      stub_request(:post, RubyAI::Configuration::BASE_URL)
        .to_return(status: status, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns parsed JSON response when using configuration object' do
      expect(client.call).to eq(response_body)
    end
  end
end
require 'rspec'
require_relative '../lib/rubyai'

RSpec.describe RubyAI::Client do
  describe '#mode' do
    it 'changes the model' do
      client = RubyAI::Client.new('your_api_key', 'Who am i?')
      expect { client.mode('gpt-4') }.to change { client.model }.to('gpt-4')
    end
  end
end

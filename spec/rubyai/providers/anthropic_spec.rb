require_relative '../../../lib/rubyai/providers/anthropic'

RSpec.describe RubyAI::Providers::Anthropic do
  describe '.models' do 
    it 'should return an list of models' do 
      expect(described_class.models).to eq( "claude-2" => "claude-2",
        "claude-instant-100k" => "claude-instant-100k",
        "claude-1" => "claude-1",
        "claude-1.3" => "claude-1.3",
        "claude-1.3-sonnet" => "claude-1.3-sonnet",
        "claude-1.3-sonnet-100k" => "claude-1.3-sonnet-100k"
      )
    end
  end
end
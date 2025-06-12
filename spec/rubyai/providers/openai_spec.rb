require_relative '../../../lib/rubyai/providers/openai'

RSpec.describe RubyAI::Providers::OpenAI do
    describe '.models' do 
    it 'should return an list of models' do 
      expect(described_class.models).to eq("gpt-3.5-turbo" => "gpt-3.5-turbo",
        "gpt-4" => "gpt-4",
        "gpt-4-32k" => "gpt-4-32k",
        "gpt-4-turbo" => "gpt-4-turbo",
        "gpt-4o-mini" => "gpt-4o-mini",
        "o1-mini" => "o1-mini",
        "o1-preview" => "o1-preview",
        "text-davinci-003" => "text-davinci-003")
    end
  end
end
require_relative "../../lib/rubyai"
require "webmock/rspec"

# spec/ruby_ai/chat_spec.rb

require "spec_helper"

RSpec.describe RubyAI::Chat do
  let(:provider) { "openai" }
  let(:model) { "gpt-4" }
  let(:temperature) { 0.9 }
  let(:messages) { ["Hello"] }
  let(:response_body) { { "reply" => "Hi!" }.to_json }

  subject(:chat) { described_class.new(provider, model: model, temperature: temperature) }

  describe "#initialize" do
    it "sets the provider, model, and temperature" do
      expect(chat.provider).to eq(provider)
      expect(chat.model).to eq(model)
      expect(chat.temperature).to eq(temperature)
    end

    it "uses default provider if none is given" do
      allow(RubyAI).to receive_message_chain(:config,
                                             :default_provider).and_return("default_provider")
      chat_instance = described_class.new(nil)
      expect(chat_instance.provider).to eq("default_provider")
    end
  end

  describe "#call" do
    context "when messages are nil or empty" do
      it "raises ArgumentError" do
        expect { chat.call(nil) }.to raise_error(ArgumentError, "Messages cannot be empty")
        expect { chat.call([]) }.to raise_error(ArgumentError, "Messages cannot be empty")
      end
    end

    context "when messages are valid" do
      let(:fake_connection) { instance_double(Faraday::Connection) }
      let(:fake_response) { instance_double(Faraday::Response, body: response_body) }
      let(:fake_connection) do
        instance_double(Faraday::Connection).tap do |conn|
          allow(conn).to receive(:post).and_return(fake_response)
          allow(conn).to receive(:headers).and_return({})
          allow(conn).to receive(:adapter)
        end
      end

      let(:url) { "https://fake.provider/api" }

      before do
        allow(RubyAI::HTTP).to receive(:build_body).with(messages, provider, model,
                                                         temperature).and_return({ body: "data" })
        allow(RubyAI::HTTP).to receive(:build_headers).with(provider).and_return({ "Authorization" => "Bearer token" })

        stub_const("RubyAI::Configuration::PROVIDERS", { [provider, model] => url })

        allow(Faraday).to receive(:new).and_return(fake_connection)
        allow(fake_connection).to receive(:headers).and_return({})
        allow(fake_connection).to receive(:adapter)

        allow(fake_connection).to receive(:post).and_return(fake_response)
      end

      it "returns parsed JSON response" do
        result = chat.call(messages)
        expect(result).to eq({ "reply" => "Hi!" })
      end
    end

    context "when Faraday connection fails" do
      before do
        allow(Faraday).to receive(:new).and_raise(Faraday::ConnectionFailed.new("no internet"))
      end

      it "raises a connection error" do
        expect { chat.call(messages) }.to raise_error("Connection error: no internet")
      end
    end

    context "when JSON parsing fails" do
      let(:bad_response) { instance_double(Faraday::Response, body: "not_json") }

      before do
        stub_const("RubyAI::Configuration::PROVIDERS", { [provider, model] => "fake_url" })

        allow(RubyAI::HTTP).to receive(:build_body).and_return({})
        allow(RubyAI::HTTP).to receive(:build_headers).and_return({})

        allow(Faraday).to receive(:new).and_return(double(
                                                     headers: {},
                                                     adapter: nil,
                                                     post: bad_response
                                                   ))

        allow(JSON).to receive(:parse).and_raise(JSON::ParserError.new("unexpected token"))
      end

      it "raises a JSON parse error" do
        expect { chat.call(messages) }.to raise_error(JSON::ParserError, "unexpected token")
      end
    end

    context "when any other error occurs" do
      before do
        allow(Faraday).to receive(:new).and_raise(StandardError.new("something went wrong"))
      end

      it "raises a generic error" do
        expect do
          chat.call(messages)
        end.to raise_error("An unexpected error occurred: something went wrong")
      end
    end
  end
end

# RubyAI - OpenAI integration Ruby gem

[![Gem Version](https://badge.fury.io/rb/rubyai.svg)](https://badge.fury.io/rb/rubyai)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/alexshapalov/rubyai/blob/main/LICENSE)

## Use the [OpenAI API 🤖 ](https://openai.com/blog/openai-api/) with Ruby! ❤️

Generate text with ChatGPT (Generative Pre-trained Transformer)



# Installation

Add this line to your application's Gemfile:

```ruby
gem "rubyai"
```

And then execute:

    $ bundle install


Or install with:

    $ gem install rubyai

and require with:

```ruby
require "rubyai"
```

# Usage

- Get your API key from [https://beta.openai.com/account/api-keys](https://beta.openai.com/account/api-keys)

- If you belong to multiple organizations, you can get your Organization ID from [https://beta.openai.com/account/org-settings](https://beta.openai.com/account/org-settings)

### Quickstart

For a quick test you can pass your token directly to a new client:

```ruby
result = RubyAI::Client.new(access_token, messages).call
```

### ChatGPT

ChatGPT is a conversational-style text generation model.
You can use it to [generate a response](https://platform.openai.com/docs/api-reference/chat/create) to a sequence of [messages](https://platform.openai.com/docs/guides/chat/introduction):

```ruby
api_key = "YOUR_API_KEY"
messages = "Who is the best chess player in history?"

result = RubyAI::Client.new(api_key, messages).call

puts result.dig("choices", 0, "message", "content")

# => As an AI language model, I do not have personal opinions, but according to historical records, Garry Kasparov is often considered as one of the best chess players in history. Other notable players include Magnus Carlsen, Bobby Fischer, and Jose Capablanca.
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.


## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/alexshapalov/rubyai>. This project is intended to be a safe, welcoming space for collaboration, and contributors.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

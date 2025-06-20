# RubyAI - OpenAI integration Ruby gem

[![Gem Version](https://badge.fury.io/rb/rubyai.svg)](https://badge.fury.io/rb/rubyai)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/alexshapalov/rubyai/blob/main/LICENSE)

## Use the [OpenAI API 🤖](https://openai.com/blog/openai-api/) with Ruby! ❤️

Generate text with ChatGPT, Claude, and Gemini!

---

## Installation

Install the latest version via Bundler:

```ruby
bundle add rubyai

Then execute:

```sh
$ bundle install
```

Or install manually:

```sh
$ gem install rubyai
```

Then require it:

```ruby
require "rubyai"
```

---

## Usage

- Get your API key from:
    
    - [OpenAI](https://beta.openai.com/account/api-keys)
        
    - [Anthropic](https://console.anthropic.com)
        
    - [Gemini](https://aistudio.google.com/apikey)
        
- If you belong to multiple organizations (OpenAI), get your Organization ID from:
    
    - [Org Settings](https://beta.openai.com/account/org-settings)
        

---

## Quickstart

For a quick test, you can pass your token directly to a new client:

```ruby
result = RubyAI::Client.new(access_token, messages).call
```

---

## ChatGPT

ChatGPT is a conversational-style text generation model. You can use it to generate a response to a sequence of messages:

```ruby
api_key = "YOUR API KEY"
messages = "Who is the best chess player in history?"

result = RubyAI::Client.new(api_key: api_key, messages: messages, model: "gpt-4").call
puts result.dig("choices", 0, "message", "content")
```

**Example output:**

> As an AI language model, I do not have personal opinions, but according to historical records, Garry Kasparov is often considered as one of the best chess players in history. Other notable players include Magnus Carlsen, Bobby Fischer, and Jose Capablanca.

---

TODO(because now you can't): 
~~You can also pass client variables using a configuration file:

```ruby
configuration = RubyAI::Configuration.new(
  api_key: "YOUR API KEY",
  messages: "Who is the best chess player in history?"
)
client = RubyAI::Client.new(configuration)
result = client.call
puts result.dig("choices", 0, "message", "content")
```
~~

---

If you're using Rails, you can use the `configure` block:

```ruby
RubyAI.configure do |config|
  config.api_key = "YOUR API KEY"
  config.messages = "Who is the best chess player in history?"
  config.model = "gpt-4o-mini"
end
```

---

### Configuration

Our gem uses separate configurations for each provider:

```ruby
# For OpenAI
RubyAI.config.openai.configure do |config|
  config.api = "your-api"
  config.model = "o1-mini"
  config.temperature = 0.75
end

# For Anthropic
RubyAI.config.anthropic.configure do |config|
  config.api = "your-api"
  config.model = "claude-2"
  config.temperature = 0.75
  config.max_tokens = 1000
end

# For Gemini
RubyAI.config.gemini.configure do |config|
  config.api = "your-api"
  config.model = "gemini-1.5-pro"
  config.temperature = 0.75
  config.max_tokens = 1000
end
```

---

### Chat

After configuration, you can chat with models using the `Chat` class:

```ruby
claude2 = RubyAI::Chat.new("anthropic", model: "claude-2")
claude2.call("Hello world") # => Hash response

# Or

gpt = RubyAI::Chat.new("openai", "gpt-4", temperature: 1)
gpt.call("Hello world!") # => Hash response
```

---

### Supported Models

We support most popular GPT models:

```ruby
p RubyAI.config.models

"openai" => {
  "gpt-3.5-turbo" => "gpt-3.5-turbo",
  "gpt-4" => "gpt-4",
  "gpt-4-32k" => "gpt-4-32k",
  "gpt-4-turbo" => "gpt-4-turbo",
  "gpt-4o-mini" => "gpt-4o-mini",
  "o1-mini" => "o1-mini",
  "o1-preview" => "o1-preview",
  "text-davinci-003" => "text-davinci-003"
},
"anthropic" => {
  "claude-2" => "claude-2",
  "claude-instant-100k" => "claude-instant-100k",
  "claude-1" => "claude-1",
  "claude-1.3" => "claude-1.3",
  "claude-1.3-sonnet" => "claude-1.3-sonnet",
  "claude-1.3-sonnet-100k" => "claude-1.3-sonnet-100k"
},
"gemini" => {
  "gemini-1.5-pro" => "gemini-1.5-pro",
  "gemini-1.5-flash" => "gemini-1.5-flash",
  "gemini-1.0-pro" => "gemini-1.0-pro"
}
```

---

## TODO

-  Support Gemini configuration via `configure` block
-  Implement more LLM support    
-  Stream responses

---

## Development

After checking out the repo, run:

```sh
bin/setup
```

You can also run:

```sh
bin/console
```

To install this gem onto your local machine:

```sh
bundle exec rake install
```

---

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/alexshapalov/rubyai](https://github.com/alexshapalov/rubyai).  
This project is intended to be a safe, welcoming space for collaboration.

---

## License

This gem is open source under the [MIT License](https://opensource.org/licenses/MIT).

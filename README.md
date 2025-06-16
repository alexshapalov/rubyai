# RubyAI - OpenAI integration Ruby gem

  

[![Gem Version](https://badge.fury.io/rb/rubyai.svg)](https://badge.fury.io/rb/rubyai)

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/alexshapalov/rubyai/blob/main/LICENSE)

  

## Use the [OpenAI API 🤖 ](https://openai.com/blog/openai-api/) with Ruby! ❤️

  

Generate text with ChatGPT, Claude and Gemini!

  
  

# Installation

install a latest version via Bundler: 

```ruby 
bundle add rubyai
```

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

  
- Get your API key from [https://beta.openai.com/account/api-keys](https://beta.openai.com/account/api-keys), https://console.anthropic.com, https://aistudio.google.com/apikey

- If you belong to multiple organizations, you can get your Organization ID from [https://beta.openai.com/account/org-settings](https://beta.openai.com/account/org-settings) 
  
### Configuration 
Our gem is using separate configurations for every provider it supports, example:
```ruby 
# for openai LLM's it could be: 
RubyAI.configuration.openai.configure do |config|
	config.api = "your-api" 
	config.model = "o1-mini"
	config.temoperature = 0.75
end

# for anthropic: 
RubyAI.configuration.anthropic.configure do |config| 
	config.api = "your-api"
	config.model="claude-2"
	temperature = 0.75
	config.max_tokens = 1000 
end

# for gemini: 
RubyAI.configuration.gemini.configure do |config| 
	config.api = "your-api"
	config.model="gemini-1.5-pro"
	temperature = 0.75
	config.max_tokens = 1000 
end
```

### Chat 
After configuration you can chat with models by calling `Chat` class, example: 
```ruby
claude2 = RubyAI::Chat.new('anthropic', model: "claude-2")
claude2.call("Hello world") # => Hash response
# Or 

gpt = RubyAI::Chat.new("openai", "gpt-4", temperature: 1)
gpt.call("Hello world!") # => Hash response
```
###

  

We support most of the popular GPT models:

  
```ruby
p RubyAI::Configuration::MODELS.each.each_key
"openai" =>
  {"gpt-3.5-turbo" => "gpt-3.5-turbo",
   "gpt-4" => "gpt-4",
   "gpt-4-32k" => "gpt-4-32k",
   "gpt-4-turbo" => "gpt-4-turbo",
   "gpt-4o-mini" => "gpt-4o-mini",
   "o1-mini" => "o1-mini",
   "o1-preview" => "o1-preview",
   "text-davinci-003" => "text-davinci-003"},
 "anthropic" =>
  {"claude-2" => "claude-2",
   "claude-instant-100k" => "claude-instant-100k",
   "claude-1" => "claude-1",
   "claude-1.3" => "claude-1.3",
   "claude-1.3-sonnet" => "claude-1.3-sonnet",
   "claude-1.3-sonnet-100k" => "claude-1.3-sonnet-100k"},
 "gemini" => {"gemini-1.5-pro" => "gemini-1.5-pro", "gemini-1.5-flash" => "gemini-1.5-flash", "gemini-1.0-pro" => "gemini-1.0-pro"}}

```


### TODO: 


1. Support for Gemini models to be configurated via `configure` block
2. Implement more LLM's support
3. Write an Specs for most of use cases
4. Stream responses


## Development
  

After checking out the repo, run `bin/setup` to install dependencies. You can run `bin/console` for an interactive prompt that will allow you to experiment.

  

To install this gem onto your local machine, run `bundle exec rake install`.

  
  

## Contributing

  

Bug reports and pull requests are welcome on GitHub at <https://github.com/alexshapalov/rubyai>. This project is intended to be a safe, welcoming space for collaboration, and contributors.

  

## License

  

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
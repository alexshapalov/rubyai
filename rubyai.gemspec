Gem::Specification.new do |s|
  s.name        = "rubyai"
  s.version     = "0.3.2"
  s.summary     = "A Ruby gem for the OpenAI (GPT-4) API"
  s.description = "RubyAI is a wrapper for the OpenAI API that allows you to interact with GPT-3 and GPT-4 from within Ruby applications. It provides simple methods for integrating language model capabilities into your Ruby projects."
  s.homepage    = "https://github.com/alexshapalov/rubyai"
  s.authors     = ["Alex Shapalov"]
  s.license     = "MIT"

  s.files = Dir.glob("**/*").select { |f| File.file?(f) } + ["README.md", "LICENSE.txt"]

  s.require_paths = ["."]
  s.required_ruby_version = ">= 2.7"

  s.add_dependency "faraday", "~> 2.0"
  s.add_development_dependency "rspec", "~> 3.10"

  s.metadata = {
    "source_code_uri" => "https://github.com/alexshapalov/rubyai",
    "changelog_uri"   => "https://github.com/alexshapalov/rubyai/CHANGELOG.md",
    "documentation_uri" => "https://github.com/alexshapalov/rubyai#readme"
  }
end

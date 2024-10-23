DOCS_ROOT = File.join(__dir__, "../docs")
WEBSITE = "https://docs.anycable.io"

sidebar_contents = File.read(File.join(DOCS_ROOT, "_sidebar.md"))

links = [WEBSITE]

sidebar_contents.scan(/\((\/.*)\.md\)/) do |link|
  links << File.join(WEBSITE, link)
end

puts links

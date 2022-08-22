# frozen_string_literal: true

require File.expand_path('lib/highlighter/version', __dir__)
Gem::Specification.new do |spec|
  spec.name                  = 'highlighter-client'
  spec.version               = Highlighter::Client::VERSION
  spec.authors               = ['Jono Chang']
  spec.email                 = ['engineering@silverpond.com.au']
  spec.summary               = 'Highlighter Ruby Client'
  spec.description           = 'This gem is a client for the Highlighter Web API'
  spec.homepage              = 'https://www.highlighter.ai'
  spec.license               = 'MIT'
  spec.platform              = Gem::Platform::RUBY
  spec.required_ruby_version = '>= 2.7.0'
  spec.add_dependency 'httparty', '~> 0.20'
  spec.files = ['lib/highlighter/client.rb',
                'lib/highlighter/version.rb',
                'lib/highlighter/file.rb',
                'lib/highlighter/task.rb',
                'lib/highlighter/submission.rb']
end

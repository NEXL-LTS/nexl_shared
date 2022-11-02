source "https://rubygems.org"

# Specify your gem's dependencies in nexl_shared.gemspec
gemspec

gem "rake", "~> 12.0"
gem "rspec", "~> 3.0"
gem 'rubocop'
gem 'rubocop-rails'
gem 'rubocop-rake'
gem 'rubocop-rspec'
gem 'ruby-lsp'
gem "simplecov", ">= 0.18.5"

if ENV['USE_RAILS_6_0'] == 'true'
  gem 'actionpack', "~> 6.0.0"
  gem 'activerecord', "~> 6.0.0"
  gem 'activesupport', "~> 6.0.0"
end

# NexlShared

Used for common code used between different rails engines and projects

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nexl_shared'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install nexl_shared

## Usage

```ruby
  class GraphqlController < ApplicationController
    include NexlShared::GraphqlControllerConcern
    skip_before_action :verify_authenticity_token if Rails.env.development?

    protected

      def app_schema
        AppSchema
      end
  end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/nexl_shared.


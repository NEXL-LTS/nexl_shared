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

### GraphQL Controller

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

### CheckQueueLatency

`CheckQueueLatency` monitors Sidekiq queue latency and reports errors when queues exceed acceptable thresholds.

#### Queue Types

**Standard Queues**: Queues without special naming conventions are checked against a 3-hour threshold (excluding 'imports' and 'maintenance' queues).

**Within Queues**: Queues following the `within_*` naming convention have dynamic thresholds based on their name:
- `within_a_minute` → 60 seconds
- `within_5_minutes` → 5 minutes
- `within_a_hour` → 1 hour

#### Error Threshold

By default, errors are tracked when queue latency reaches **150% of the threshold** (50% above). For example:
- `within_a_minute` → errors at 90 seconds or more
- `within_5_minutes` → errors at 7.5 minutes or more
- `within_a_hour` → errors at 90 minutes or more

This threshold multiplier can be configured:

```ruby
# config/initializers/nexl_shared.rb
NexlShared.queue_latency_error_threshold = 2.0  # Errors at 200% of threshold
```

#### Usage

Run periodically (e.g., via cron or scheduled job):

```ruby
NexlShared::CheckQueueLatency.perform_now
```

Or with custom queues and error tracker:

```ruby
NexlShared::CheckQueueLatency.new.perform(
  queues: Sidekiq::Queue.all,
  error_tracker: Rollbar
)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/nexl_shared.


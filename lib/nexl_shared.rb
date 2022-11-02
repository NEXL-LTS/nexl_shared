require "active_support"
require "nexl_shared/version"

module NexlShared
  class Error < StandardError; end
  # Your code goes here...
end

require 'nexl_shared/error_tracker'
require 'nexl_shared/graphql_controller_concern'
require 'nexl_shared/graphql_wrapper'
require 'nexl_shared/track_slow_jobs'
require 'nexl_shared/timeout_stalled_jobs'


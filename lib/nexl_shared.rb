require "active_support/core_ext"
require "nexl_shared/version"

module NexlShared
  class Error < StandardError; end
  # Your code goes here...
end

require 'nexl_shared/error_tracker'
require 'nexl_shared/graphql_controller_concern'
require 'nexl_shared/graphql_wrapper'

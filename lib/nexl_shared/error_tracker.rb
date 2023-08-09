require 'singleton'
require 'rollbar'

module NexlShared
  module ErrorTracker
    class FirstError
      include Singleton

      def self.reset
        instance.reset
      end

      def self.error(args)
        instance.error(args)
      end

      def initialize
        @error = []
      end

      def reset
        @error = []
      end

      def error(args)
        ignore_errors = ["ActiveStorage::FileNotFoundError",
                         "ActiveRecord::Deadlocked",
                         "RocketReach::ClientError",
                         "RocketReach::ServerError",
                         "Mysql2::Error"]
        return if ignore_errors.include?(args.first.class.to_s)

        @error = args if @error.blank?
      end

      def blank?
        @error.blank?
      end

      def title
        @error.first.try(:message) || @error.first || "No Errors :)"
      end

      def backtrace
        @error.first.try(:backtrace) || []
      end

      def args
        @error.second
      end
    end

    def self.error(*args)
      Rollbar.error(*args)
      FirstError.error(args)
    end

    def self.critical(*args)
      Rollbar.critical(*args)
      FirstError.error(args)
    end

    def self.warn(*args)
      Rollbar.warn(*args) if ENV['CYPRESS'].blank?
    end

    def self.info(*args)
      Rollbar.info(*args) if ENV['ROLLBAR_ENV'].blank?
    end
  end
end

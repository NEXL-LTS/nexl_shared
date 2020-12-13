require 'graphql'

module NexlShared
  class GraphqlWrapper
    class ResultError < RuntimeError
      attr_reader :errors

      def initialize(msg = "GraphQL Result Error", errors = [])
        @errors = errors || []
        super(msg)
      end
    end
    UndefinedField = Class.new(ResultError)
    ParseError = Class.new(ResultError)
    MissingRequiredArguments = Class.new(ResultError)
    ArgumentLiteralsIncompatible = Class.new(ResultError)
    UniquelyNamedOperations = Class.new(ResultError)
    NonNullableField = Class.new(ResultError)
    InvalidValue = Class.new(ResultError)

    attr_accessor :app_schema
    attr_accessor :logger
    attr_accessor :error_tracker

    def initialize(app_schema, logger: Rails.logger, error_tracker: ErrorTracker)
      self.app_schema = app_schema
      self.logger = logger
      self.error_tracker = error_tracker
    end

    def track_errors(res, schema_args)
      Array.wrap(res.dig("errors")).each do |error|
        message = error.dig("message") || error.to_s
        begin
          raise select_error_class(message), message
        rescue ResultError => e
          error_tracker.error(e, schema_args)
        end
      end
    end

    def select_error_class(message)
      if message.include?("doesn't exist on type")
        UndefinedField
      elsif message.include?("missing required arguments")
        MissingRequiredArguments
      elsif message.include?("Expected type")
        ArgumentLiteralsIncompatible
      elsif message.include?("required when multiple operations")
        UniquelyNamedOperations
      elsif message.include?("Parse error")
        ParseError
      elsif message.include?("non-nullable field")
        NonNullableField
      elsif message.include?("provided invalid value")
        InvalidValue
      else
        ResultError
      end
    end

    def self.execute!(app_schema, logger: Rails.logger, **schema_args)
      new(app_schema, logger: logger).execute!(**schema_args)
    end

    def execute!(query:, variables: {}, **schema_args)
      variables = ensure_hash(variables)
      logger.debug {
        "#{schema_args[:operation_name]}: \033[32m#{query.strip_heredoc}\033[0m#{variables}"
      }
      app_schema.execute(query, variables: variables, **schema_args)
    end

    def self.execute(app_schema, logger: Rails.logger, **schema_args)
      new(app_schema, logger: logger).execute(**schema_args)
    end

    def execute(**schema_args)
      execute!(**schema_args).tap do |res|
        track_errors(res, schema_args) if res['errors']
      end
    rescue => e
      error_tracker.error(e, **schema_args)
      logger&.error(e)

      { 'errors' => [{ 'message' => 'something has gone wrong' }] }
    end

    def ensure_hash(ambiguous_param)
      case ambiguous_param
      when String
        if ambiguous_param.present?
          ensure_hash(JSON.parse(ambiguous_param))
        else
          {}
        end
      when Hash, ActionController::Parameters
        ambiguous_param
      when nil
        {}
      else
        raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
      end
    end
  end
end
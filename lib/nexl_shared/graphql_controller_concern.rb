require 'rack/timeout/core'

module NexlShared
  module GraphqlControllerConcern
    extend ActiveSupport::Concern

    included do
      protect_from_forgery unless: -> { request.format.json? }
      rescue_from RuntimeError,
                  ActionController::ActionControllerError,
                  ActiveRecord::ActiveRecordError,
                  Rack::Timeout::RequestTimeoutException do |error|
        Rails.logger.error(error)
        ErrorTracker.error(error)
        render json: { errors: [{ message: error.message }] }
      end

      rescue_from ActionController::InvalidAuthenticityToken do |error|
        render json: { errors: [{ message: error.message }] }
      end
    end

    def execute
      rename_transaction_name
      render json: GraphqlWrapper.execute(app_schema,
                                          show_error: show_error,
                                          logger: logger,
                                          variables: params[:variables],
                                          query: params[:query],
                                          operation_name: params[:operationName],
                                          context: context)
    end

    def schema
      render plain: GraphQL::Schema::Printer.print_schema(app_schema)
    end

    protected

      def logger
        Rails.logger
      end

      def show_error
        !Rails.env.production?
      end

      def rename_transaction_name
        transaction_name = "#{params[:controller]}/#{params[:operationName]}"
        ScoutApm::Transaction.rename(transaction_name) if defined?(ScoutApm::Transaction)
      end

      def context
        { current_account: self.try(:current_account),
          current_user: self.try(:current_account).try(:user) }
      end

      def app_schema
        raise NotImplementedError, '#app_schema needs implementation'
      end
  end
end

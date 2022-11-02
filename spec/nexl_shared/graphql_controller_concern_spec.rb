require 'action_controller'
require 'action_controller/metal/exceptions'
require 'action_controller/metal/request_forgery_protection'
require 'active_record'

class SimpleQueries < GraphQL::Schema::Object
  field :lists, [String], null: false do
    argument :with, String, required: false
  end

  def lists(with: nil)
    ["Example", with, context[:string]].compact
  end
end

class SimpleSchema < GraphQL::Schema
  query(SimpleQueries)
end

module NexlShared
  class SimpleGraphqlController
    def self.protect_from_forgery(*); end

    def self.rescue_from(*); end

    include GraphqlControllerConcern

    def params
      { query: 'query($with: String) { lists(with: $with) }', variables: { 'with' => "Hello" } }
    end

    protected

      def app_schema
        SimpleSchema
      end

      def logger
      end

      def context
        { string: 'ContextString' }
      end

      def render(args)
        args.fetch(:json).as_json
      end

      def show_error
        true
      end
  end

  RSpec.describe GraphqlControllerConcern, type: :controller do
    subject { SimpleGraphqlController.new }

    describe ".execute" do
      it 'works' do
        expect(subject.execute).to eq("data" => { "lists" => ["Example", "Hello",
                                                              "ContextString"] })
      end
    end
  end
end


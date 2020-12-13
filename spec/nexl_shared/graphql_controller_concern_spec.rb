require 'spec_helper'
require 'action_controller'
require 'action_controller/metal/exceptions'
require 'action_controller/metal/request_forgery_protection'
require 'active_record'

module NexlShared
  class SimpleGraphqlController
    def self.protect_from_forgery(*); end

    def self.rescue_from(*); end

    include GraphqlControllerConcern

    def params
      {}
    end

    protected

      def app_schema
      end

      def logger
      end

      def render(*); end
  end

  RSpec.describe GraphqlControllerConcern, type: :controller do
    subject { SimpleGraphqlController.new }

    describe ".execute" do
      it 'works' do
        subject.execute
      end
    end
  end
end


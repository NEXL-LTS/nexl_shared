module NexlShared
  RSpec.describe GraphqlWrapper do
    subject do
      described_class.new(app_schema, logger: logger, error_tracker: error_tracker,
                                      re_raise_errors: false)
    end

    let(:app_schema) { class_double(GraphQL::Schema, execute: {}) }
    let(:logger) { Logger.new(StringIO.new) }
    let(:error_tracker) { class_double(ErrorTracker, error: true) }


    def execute(**args)
      subject.execute(**args)
    end

    it 'generates error for unknown field' do
      error_result = { 'errors' => [{ 'message' => "doesn't exist on type" }] }
      allow(app_schema).to receive(:execute).and_return(error_result)

      expect(execute(query: "blah")).to eq(error_result)
      expect(app_schema).to have_received(:execute).
        with("blah", { :context => nil, :operation_name => nil, :variables => {} })
      expect(error_tracker).to have_received(:error).
        with(kind_of(GraphqlWrapper::UndefinedField), { :query => "blah" })
    end

    it 'generates error for missing required arguments' do
      allow(app_schema).to receive(:execute).
        and_return({ 'errors' => [{ 'message' => "missing required arguments" }] })

      execute(query: "blah")
      expect(error_tracker).to have_received(:error).
        with(kind_of(GraphqlWrapper::MissingRequiredArguments), { :query => "blah" })
    end

    it 'generates error for Expected type' do
      allow(app_schema).to receive(:execute).
        and_return({ 'errors' => [{ 'message' => "Expected type" }] })

      execute(query: "blah")
      expect(error_tracker).to have_received(:error).
        with(kind_of(GraphqlWrapper::ArgumentLiteralsIncompatible), { :query => "blah" })
    end

    it 'generates error for required when multiple operations' do
      allow(app_schema).to receive(:execute).
        and_return({ 'errors' => [{ 'message' => "required when multiple operations" }] })

      execute(query: "blah")
      expect(error_tracker).to have_received(:error).
        with(kind_of(GraphqlWrapper::UniquelyNamedOperations), { :query => "blah" })
    end
  end
end
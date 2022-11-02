require 'active_support'

module NexlShared
  # rubocop:disable RSpec/VerifiedDoubles
  RSpec.describe CheckQueueLatency do
    let(:job) { subject }
    let(:error_tracker) { class_double(ErrorTracker, critical: nil) }
    let(:queues) { [] }

    context 'when latency is acceptable' do
      before do
        queues << double('Sidekiq::Queue', latency: 59.minutes.to_i, name: 'default')
        job.perform(queues: queues, error_tracker: error_tracker)
      end

      it { expect(error_tracker).not_to have_received(:critical) }
    end

    context 'when latency is too high' do
      before do
        queues << double('Sidekiq::Queue', latency: 3.hours.to_i, name: 'interactions')
        job.perform(queues: queues, error_tracker: error_tracker)
      end

      it { expect(error_tracker).to have_received(:critical) }
    end

    context 'when maintenance or imports' do
      before do
        queues << double('Sidekiq::Queue', latency: 24.hours.to_i, name: 'maintenance')
        queues << double('Sidekiq::Queue', latency: 24.hours.to_i, name: 'imports')
        job.perform(queues: queues, error_tracker: error_tracker)
      end

      it { expect(error_tracker).not_to have_received(:critical) }
    end
  end
  # rubocop:enable RSpec/VerifiedDoubles
end

require 'active_support'

module NexlShared
  # rubocop:disable RSpec/VerifiedDoubles
  RSpec.describe CheckQueueLatency do
    let(:job) { subject }
    let(:error_tracker) { class_double(ErrorTracker, critical: nil) }
    let(:queues) { [] }

    context 'when latency queue' do
      before do
        queues << double('Sidekiq::Queue', latency: queue_latency, name: queue_name)
        job.perform(queues: queues, error_tracker: error_tracker)
      end

      context 'when within_a_minute' do
        let(:queue_name) { 'within_a_minute' }

        context 'when latency is too high' do
          let(:queue_latency) { 2.minutes.to_i }

          it { expect(error_tracker).to have_received(:critical) }
        end

        context 'when latency is acceptable' do
          let(:queue_latency) { 1.minute.to_i }

          it { expect(error_tracker).not_to have_received(:critical) }
        end
      end

      context 'when within_5_minutes' do
        let(:queue_name) { 'within_5_minutes' }

        context 'when latency is too high' do
          let(:queue_latency) { 6.minutes.to_i }

          it { expect(error_tracker).to have_received(:critical) }
        end

        context 'when latency is acceptable' do
          let(:queue_latency) { 5.minutes.to_i }

          it { expect(error_tracker).not_to have_received(:critical) }
        end
      end

      context 'when within_a_hour' do
        let(:queue_name) { 'within_a_hour' }

        context 'when latency is too high' do
          let(:queue_latency) { 61.minutes.to_i }

          it { expect(error_tracker).to have_received(:critical) }
        end

        context 'when latency is acceptable' do
          let(:queue_latency) { 1.hour.to_i }

          it { expect(error_tracker).not_to have_received(:critical) }
        end
      end

      context 'when within_invalid' do
        let(:queue_name) { 'within_invalid' }
        let(:queue_latency) { 1.minute.to_i }

        it { expect(error_tracker).not_to have_received(:critical) }
      end

      context 'when within_some_time' do
        let(:queue_name) { 'within_some_time' }
        let(:queue_latency) { 1.minute.to_i }

        it { expect(error_tracker).not_to have_received(:critical) }
      end

      context 'when within_a_madeuptime' do
        let(:queue_name) { 'within_a_madeuptime' }
        let(:queue_latency) { 1.minute.to_i }

        it { expect(error_tracker).not_to have_received(:critical) }
      end
    end

    context 'when no latency queue' do
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
  end
  # rubocop:enable RSpec/VerifiedDoubles
end

require 'active_job'

ActiveJob::Base.logger = Logger.new(IO::NULL)

class SlowJob < ActiveJob::Base # rubocop:disable Rails/ApplicationJob
  include NexlShared::TrackSlowJobs

  cattr_accessor :job_slow_time

  def perform(sleep_time:)
    sleep(sleep_time)
  end

  protected

    def job_slow_time
      self.class.job_slow_time
    end
end

module NexlShared
  RSpec.describe TrackSlowJobs do
    describe '#track_slow_jobs' do
      before do
        allow(ErrorTracker).to receive(:warn)
        SlowJob.job_slow_time = 1.second
      end

      it do
        SlowJob.perform_now(sleep_time: 2.seconds)

        expect(NexlShared::ErrorTracker).to have_received(:warn)
      end

      it do
        SlowJob.perform_now(sleep_time: 0.seconds)

        expect(NexlShared::ErrorTracker).not_to have_received(:warn)
      end
    end
  end
end

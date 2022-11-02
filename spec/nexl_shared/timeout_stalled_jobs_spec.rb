require 'active_job'

ActiveJob::Base.logger = Logger.new(IO::NULL)

class StallingJob < ActiveJob::Base # rubocop:disable Rails/ApplicationJob
  include NexlShared::TimeoutStalledJobs

  def perform
    sleep(4)
  end

  protected

    def stall_time
      2.seconds
    end
end

class NonStallingJob < ActiveJob::Base # rubocop:disable Rails/ApplicationJob
  include NexlShared::TimeoutStalledJobs

  def perform
    sleep(0.1)
  end

  protected

    def stall_time
      2.seconds
    end
end

class TimeOutJob < ActiveJob::Base # rubocop:disable Rails/ApplicationJob
  include NexlShared::TimeoutStalledJobs

  def perform
    Timeout.timeout(2) do
      sleep(4)
    end
  end

  protected

    def stall_time
      6.seconds
    end
end

module NexlShared
  RSpec.describe TimeoutStalledJobs do
    describe '#timeout_stalled_jobs' do
      it 'stalls' do
        job = StallingJob.new
        result = job.perform_now

        expect(result).to be_a(TimeoutStalledJobs::StalledJobError)
      end

      it 'does not stall' do
        job = NonStallingJob.new
        result = job.perform_now
        expect(result).not_to be_a(TimeoutStalledJobs::StalledJobError)
      end

      it 'does not stall when timing out' do
        job = TimeOutJob.new

        expect { job.perform_now }.to raise_error(Timeout::Error)
      end
    end
  end
end

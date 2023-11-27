module NexlShared
  module TimeoutStalledJobs
    extend ActiveSupport::Concern

    StalledJobError = Class.new(Timeout::Error)

    included do
      discard_on(StalledJobError) do |job, error|
        ErrorTracker.error(error, class: job.class, arguments: job.arguments)
      end

      around_perform :timeout_stalled_jobs
    end

    protected

      def stall_time
        2.hours
      end

      def timeout_stalled_jobs(&)
        start_time = Time.current
        Timeout.timeout(stall_time, &)
      rescue Timeout::Error => e
        raise StalledJobError, e.message if Time.current - start_time >= stall_time

        raise e
      end
  end
end

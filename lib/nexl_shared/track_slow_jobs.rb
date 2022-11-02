module NexlShared
  module TrackSlowJobs
    extend ActiveSupport::Concern

    class TimeTracker
      attr_accessor :start_time, :arguments, :job_name, :slow_time

      def initialize(arguments:, job_name:)
        @arguments = arguments
        @job_name = job_name
      end

      def start(current_time = Time.current)
        self.start_time = current_time
      end

      def done(tracker = ErrorTracker)
        time_taken = (Time.current - start_time).to_i

        return if time_taken < slow_time.seconds

        tracker.warn("Slow #{job_name}", time_taken: time_taken, arguments: arguments)
      end
    end


    included do
      around_perform :track_slow_jobs
    end

    protected

      def job_slow_time
        4.minutes
      end

      def slow_job_name
        "Job: #{self.class}"
      end

      def track_slow_jobs
        tracker = TimeTracker.new(job_name: slow_job_name, arguments: arguments)
        tracker.slow_time = job_slow_time

        tracker.start
        yield
        tracker.done
      end
  end
end

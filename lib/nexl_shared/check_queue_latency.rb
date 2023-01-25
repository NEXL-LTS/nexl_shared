module NexlShared
  class CheckQueueLatency
    require 'action_view/helpers/date_helper'

    include ActionView::Helpers::DateHelper

    def self.perform_now
      new.perform
    end

    def perform(queues: nil, error_tracker: Rollbar)
      queues ||= Sidekiq::Queue.all
      queues.each do |queue|
        check_queue(queue, error_tracker)
      end
    end

    private

      def check_queue(queue, error_tracker)
        return if %w[imports maintenance].include?(queue.name)

        queue_latency = queue.latency.seconds
        return if queue_latency < 3.hours

        latency = time_ago_in_words(queue_latency.ago)
        txt = "#{ENV['DEFAULT_HOST']} #{queue.name} has latency of #{latency}"
        error_tracker.critical(txt, queue_latency: queue_latency)
      end
  end
end

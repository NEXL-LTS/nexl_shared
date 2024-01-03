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
        if queue.name.starts_with?('within_')
          check_latency(queue, error_tracker)
        else
          check_queue(queue, error_tracker)
        end
      end
    end

    private

      def check_queue(queue, error_tracker)
        return if %w[imports maintenance].include?(queue.name)

        queue_latency = queue.latency.seconds
        return if queue_latency < 3.hours

        track_error(error_tracker, queue_latency, queue.name)
      end

      def check_latency(queue, error_tracker)
        amount, unit = queue.name.gsub('within_', '').split('_')
        amount = '1' if amount == 'a'
        amount = amount.to_i
        return if amount.zero?
        return if unit.nil? || !amount.respond_to?(unit)

        queue_latency = queue.latency.seconds
        return if queue_latency <= amount.public_send(unit)

        track_error(error_tracker, queue_latency, queue.name)
      end

      def track_error(error_tracker, queue_latency, queue_name)
        latency = time_ago_in_words(queue_latency.ago)
        txt = "#{ENV['DEFAULT_HOST']} #{queue_name} has latency of #{latency}"
        error_tracker.critical(txt, queue_latency: queue_latency)
      end
  end
end

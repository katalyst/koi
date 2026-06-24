# frozen_string_literal: true

class BackgroundJob
  include ActiveModel::Model

  # @return [SolidQueue::Job]
  attr_reader :job

  delegate_missing_to :job

  # @param [SolidQueue::Job] job
  def initialize(job)
    @job = job
  end

  # ActiveJob's job id, stored in the serialized payload rather than as a column.
  def job_id
    job.arguments["job_id"]
  end

  # Serialized as an ISO8601 string in the payload; parse so views can format it.
  def enqueued_at
    job.arguments["enqueued_at"]&.then { |value| Time.iso8601(value) }
  end

  # Human-readable run time once finished, e.g. "1 minute and 35 seconds".
  def duration
    return unless finished? && enqueued_at

    seconds   = finished_at - enqueued_at
    precision = case seconds
                when 0...1  then 2
                when 1...10 then 1
                else             0
                end
    ActiveSupport::Duration.build(seconds.round(precision)).inspect
  end

  def to_param
    active_job_id
  end

  def to_s
    class_name
  end
end

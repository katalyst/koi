# frozen_string_literal: true

class BackgroundJob
  include ActiveModel::Model

  # @return [SolidQueue::Job]
  attr_reader :job

  delegate_missing_to :job

  # The SolidQueue relation backing each job state, in display order. A job that
  # isn't finished holds exactly one execution; finished jobs carry a finished_at.
  def self.states
    {
      pending:     SolidQueue::Job.where.associated(:ready_execution),
      scheduled:   SolidQueue::Job.where.associated(:scheduled_execution),
      in_progress: SolidQueue::Job.where.associated(:claimed_execution),
      blocked:     SolidQueue::Job.where.associated(:blocked_execution),
      failed:      SolidQueue::Job.failed,
      completed:   SolidQueue::Job.finished,
    }
  end

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

  # The arguments the job was enqueued with, from the serialized payload.
  def serialized_arguments
    job.arguments["arguments"]
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

  # SolidQueue::Job#discard only acts on a ready, claimed, or failed execution;
  # it's a no-op for scheduled, blocked, or finished jobs.
  def discardable?
    ready_execution.present? || claimed_execution.present? || failed_execution.present?
  end

  # Exception class and message from the current failure, e.g. "RuntimeError: boom".
  def failure_reason
    return unless (failure = failed_execution)

    "#{failure.exception_class}: #{failure.message}"
  end

  def state
    if finished?
      :finished
    elsif failed?
      :failed
    elsif claimed_execution.present?
      :in_progress
    elsif blocked_execution.present?
      :blocked
    elsif scheduled_execution.present?
      :scheduled
    else
      :pending
    end
  end

  # Backtrace lines from the current failure, joined into a single string.
  def backtrace
    failed_execution&.backtrace&.join("\n")
  end

  def to_param
    active_job_id
  end

  def to_s
    class_name
  end
end

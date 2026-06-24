# frozen_string_literal: true

class RecurringTask
  include ActiveModel::Model

  # @return [SolidQueue::RecurringTask]
  attr_reader :task

  delegate_missing_to :task

  # @param [SolidQueue::RecurringTask] task
  def initialize(task)
    @task = task
  end

  def job_class
    class_name.presence || command
  end

  def run
    task.enqueue(at: Time.current)
  end

  def to_param
    key
  end

  def to_s
    key
  end
end

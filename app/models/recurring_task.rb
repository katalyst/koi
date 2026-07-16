# frozen_string_literal: true

class RecurringTask
  include ActiveModel::Model

  module Scopes
    def admin_search(query)
      where(
        <<~SQL.squish,
          solid_queue_recurring_tasks.key LIKE :query
          OR solid_queue_recurring_tasks.class_name LIKE :query
        SQL
        query: "%#{query}%",
      )
    end
  end

  def self.scope
    SolidQueue::RecurringTask.extending(Scopes)
  end

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

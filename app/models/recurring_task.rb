# frozen_string_literal: true

class RecurringTask
  include ActiveModel::Model

  module Scopes
    def admin_search(query)
      pattern            = "%#{SolidQueue::RecurringTask.sanitize_sql_like(query)}%"
      table              = SolidQueue::RecurringTask.arel_table
      key_matches        = table[:key].matches(pattern)
      class_name_matches = table[:class_name].matches(pattern)
      where(key_matches.or(class_name_matches))
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

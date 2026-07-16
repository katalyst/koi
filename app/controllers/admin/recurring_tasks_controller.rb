# frozen_string_literal: true

module Admin
  class RecurringTasksController < ApplicationController
    before_action :set_recurring_task, only: %i[show run]

    attr_reader :recurring_task

    def index
      collection = Collection.with_params(params).apply(RecurringTask.scope)

      render locals: { collection: }
    end

    def show
      jobs = JobsCollection.with_params(params).apply(jobs_scope)

      render locals: { recurring_task:, jobs: }
    end

    def run
      recurring_task.run

      redirect_to(admin_recurring_task_path(recurring_task), status: :see_other)
    end

    private

    def set_recurring_task
      task            = SolidQueue::RecurringTask.find_by!(key: params.expect(:key))
      @recurring_task = RecurringTask.new(task)
    end

    def jobs_scope
      SolidQueue::Job.joins(:recurring_execution)
        .where(solid_queue_recurring_executions: { task_key: recurring_task.key })
        .order(scheduled_at: :desc)
    end

    class Collection < Admin::Collection
      config.sorting  = :key
      config.paginate = true

      attribute :key, :string
      attribute :schedule, :string
    end

    class JobsCollection < Admin::Collection
      config.paginate = true

      def apply(items)
        super.tap do
          self.items = self.items.map { |job| BackgroundJob.new(job) }
        end
      end

      def model
        BackgroundJob
      end

      def model_name
        BackgroundJob.model_name
      end
    end
  end
end

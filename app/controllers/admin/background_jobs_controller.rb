# frozen_string_literal: true

module Admin
  class BackgroundJobsController < ApplicationController
    before_action :set_background_job, only: %i[show retry discard]

    attr_reader :collection, :background_job

    def index       = render_state(:pending)
    def scheduled   = render_state(:scheduled)
    def in_progress = render_state(:in_progress)
    def blocked     = render_state(:blocked)
    def failed      = render_state(:failed)
    def completed   = render_state(:completed)

    def show
      render locals: { background_job: }
    end

    def retry
      background_job.retry

      redirect_to admin_background_jobs_path, status: :see_other
    end

    def discard
      redirect_target = background_job.failed? ? failed_admin_background_jobs_path : admin_background_jobs_path

      background_job.discard

      redirect_to redirect_target, status: :see_other
    end

    def retry_all
      SolidQueue::Job.failed.where(id: params[:id]).find_each(&:retry)

      redirect_back_or_to failed_admin_background_jobs_path, status: :see_other
    end

    def discard_all
      SolidQueue::Job.where(id: params[:id]).find_each(&:discard)

      redirect_back_or_to admin_background_jobs_path, status: :see_other
    end

    private

    def render_state(state)
      states      = BackgroundJob.states
      @collection = Collection.with_params(params).apply(states.fetch(state).strict_loading)

      render locals: { collection:, state_counts: states.transform_values(&:count) }
    end

    def set_background_job
      job             = SolidQueue::Job.find_by!(active_job_id: params.expect(:active_job_id))
      @background_job = BackgroundJob.new(job)
    end

    class Collection < Admin::Collection
      config.paginate = true

      attribute :class_name, :string
      attribute :queue_name, :string
      attribute :scheduled_at, :date
    end
  end
end

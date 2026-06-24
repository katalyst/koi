# frozen_string_literal: true

module Admin
  class BackgroundJobsController < ApplicationController
    before_action :set_background_job, only: %i[show]

    attr_reader :collection, :background_job

    def index
      @collection = Collection.with_params(params).apply(SolidQueue::Job.strict_loading)

      render locals: { collection: }
    end

    def failed
      @collection = Collection.with_params(params).apply(SolidQueue::Job.failed.strict_loading)

      render locals: { collection: }
    end

    def show
      render locals: { background_job: }
    end

    private

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

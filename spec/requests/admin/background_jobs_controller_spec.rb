# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::BackgroundJobsController do
  let(:admin) { create(:admin) }
  let(:active_job) { Admin::DeviceAuthorizationsCleanupJob.new }
  let(:solid_job) { SolidQueue::Job.enqueue(active_job) }
  let(:background_job) { BackgroundJob.new(solid_job) }

  include_context "with admin session"

  describe "GET /admin/background_jobs" do
    let(:action) { get admin_background_jobs_path }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /admin/background_jobs/failed" do
    let(:action) { get failed_admin_background_jobs_path }

    before { SolidQueue::FailedExecution.create!(job: solid_job, exception: StandardError.new("boom")) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /admin/background_jobs/:id" do
    let(:action) { get admin_background_job_path(background_job) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end

    context "when the job has failed" do
      before { SolidQueue::FailedExecution.create!(job: solid_job, exception: StandardError.new("boom")) }

      it "renders successfully" do
        action
        expect(response).to have_http_status(:success)
      end
    end
  end
end

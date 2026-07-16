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

    it "sorts by scheduled time by default" do
      first  = solid_job
      second = SolidQueue::Job.enqueue(Admin::DeviceAuthorizationsCleanupJob.new)
      first.update!(scheduled_at: 1.hour.ago)
      second.update!(scheduled_at: Time.current)

      action

      expect(response.parsed_body.css("tbody td a").pluck(:href))
        .to eq([second, first].map { |job| admin_background_job_path(job.active_job_id) })
    end
  end

  describe "GET /admin/background_jobs/completed" do
    let(:action) { get completed_admin_background_jobs_path }

    before { solid_job.update!(finished_at: Time.current) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end

    it "sorts by finished time by default" do
      first  = solid_job
      second = SolidQueue::Job.enqueue(Admin::DeviceAuthorizationsCleanupJob.new)
      first.update!(finished_at: 1.hour.ago)
      second.update!(finished_at: Time.current)

      action

      expect(response.parsed_body.css("tbody td a").pluck(:href))
        .to eq([second, first].map { |job| admin_background_job_path(job.active_job_id) })
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

    it "sorts by last failed time by default" do
      first  = solid_job
      second = SolidQueue::Job.enqueue(Admin::DeviceAuthorizationsCleanupJob.new)
      SolidQueue::FailedExecution.create!(job: second, exception: StandardError.new("boom"))
      first.update!(updated_at: 1.hour.ago)
      second.update!(updated_at: Time.current)

      action

      expect(response.parsed_body.css("tbody td a").pluck(:href))
        .to eq([second, first].map { |job| admin_background_job_path(job.active_job_id) })
    end
  end

  describe "GET /admin/background_jobs/scheduled" do
    let(:action) { get scheduled_admin_background_jobs_path }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /admin/background_jobs/in_progress" do
    let(:action) { get in_progress_admin_background_jobs_path }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /admin/background_jobs/blocked" do
    let(:action) { get blocked_admin_background_jobs_path }

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

  describe "POST /admin/background_jobs/:id/retry" do
    let(:action) { post retry_admin_background_job_path(background_job) }

    before { SolidQueue::FailedExecution.create!(job: solid_job, exception: StandardError.new("boom")) }

    it_behaves_like "requires admin"

    it "redirects to the index" do
      action
      expect(response).to redirect_to(admin_background_jobs_path)
    end

    it "clears the failure" do
      action
      expect(solid_job.reload.failed_execution).to be_nil
    end
  end

  describe "DELETE /admin/background_jobs/:id/discard" do
    let(:action) { delete discard_admin_background_job_path(background_job) }

    before { SolidQueue::FailedExecution.create!(job: solid_job, exception: StandardError.new("boom")) }

    it_behaves_like "requires admin"

    it "redirects to the failed jobs" do
      action
      expect(response).to redirect_to(failed_admin_background_jobs_path)
    end

    it "destroys the job" do
      action
      expect(SolidQueue::Job).not_to exist(solid_job.id)
    end
  end

  describe "POST /admin/background_jobs/retry_all" do
    let(:action) { post retry_all_admin_background_jobs_path, params: { id: [solid_job.id] } }

    before { SolidQueue::FailedExecution.create!(job: solid_job, exception: StandardError.new("boom")) }

    it_behaves_like "requires admin"

    it "redirects to the failed jobs" do
      action
      expect(response).to redirect_to(failed_admin_background_jobs_path)
    end

    it "clears the failure" do
      action
      expect(solid_job.reload.failed_execution).to be_nil
    end
  end

  describe "DELETE /admin/background_jobs/discard_all" do
    let(:action) { delete discard_all_admin_background_jobs_path, params: { id: [solid_job.id] } }

    before { SolidQueue::FailedExecution.create!(job: solid_job, exception: StandardError.new("boom")) }

    it_behaves_like "requires admin"

    it "redirects to the index" do
      action
      expect(response).to redirect_to(admin_background_jobs_path)
    end

    it "destroys the selected jobs" do
      action
      expect(SolidQueue::Job).not_to exist(solid_job.id)
    end
  end
end

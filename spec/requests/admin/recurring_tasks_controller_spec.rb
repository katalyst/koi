# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::RecurringTasksController do
  let(:admin) { create(:admin) }
  let(:task) do
    SolidQueue::RecurringTask.create!(
      key:        "device_authorizations_cleanup",
      class_name: "Admin::DeviceAuthorizationsCleanupJob",
      schedule:   "* * * * *",
      arguments:  [],
    )
  end
  let(:recurring_task) { RecurringTask.new(task) }

  include_context "with admin session"

  describe "GET /admin/recurring_tasks" do
    let(:action) { get admin_recurring_tasks_path }

    before { task }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /admin/recurring_tasks/:key" do
    let(:action) { get admin_recurring_task_path(recurring_task) }

    before { task.enqueue(at: Time.current) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /admin/recurring_tasks/:key/run" do
    let(:action) { post run_admin_recurring_task_path(recurring_task) }

    it_behaves_like "requires admin"

    it "redirects to the recurring task" do
      action
      expect(response).to redirect_to(admin_recurring_task_path(recurring_task))
    end

    it "enqueues the task" do
      expect { action }.to have_enqueued_job(Admin::DeviceAuthorizationsCleanupJob)
    end
  end
end

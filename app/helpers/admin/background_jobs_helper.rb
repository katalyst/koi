# frozen_string_literal: true

module Admin
  module BackgroundJobsHelper
    # The listing path for a job state. Pending is the index; the rest are
    # collection routes named after the state.
    def background_job_state_path(state)
      if state == :pending
        admin_background_jobs_path
      else
        public_send(:"#{state}_admin_background_jobs_path")
      end
    end
  end
end

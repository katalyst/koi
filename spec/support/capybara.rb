# frozen_string_literal: true

require "capybara/rspec"

module WaitForTurbo
  def wait_for_form_submission
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until form_submission_complete?
    end
  end

  def form_submission_complete?
    page.evaluate_script("Turbo.navigator.formSubmission.state === 'stopped'")
  end
end

RSpec.configure do |config|
  config.include Capybara::RSpecMatchers, type: :request
  config.include WaitForTurbo, type: :system
end

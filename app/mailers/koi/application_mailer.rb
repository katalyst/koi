# frozen_string_literal: true

module Koi
  class ApplicationMailer < ActionMailer::Base
    default from: "support@katalyst.com.au"
    layout "mailer"
  end
end

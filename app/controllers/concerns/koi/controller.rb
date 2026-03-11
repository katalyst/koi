# frozen_string_literal: true

module Koi
  module Controller
    extend ActiveSupport::Concern

    included do
      include Koi::Controller::IsAdminController

      authenticate_local_admins Rails.env.development?

      helper Koi::ApplicationHelper
      helper Koi::DefinitionListHelper
    end
  end
end

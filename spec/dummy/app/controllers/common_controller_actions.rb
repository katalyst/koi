# frozen_string_literal: true

module CommonControllerActions
  extend ActiveSupport::Concern

  include Katalyst::Navigation::HasNavigation
  include Koi::HasAdminUsers

  included do
    protect_from_forgery
    helper :all
  end
end

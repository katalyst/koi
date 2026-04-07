# frozen_string_literal: true

module Koi
  class Current < ActiveSupport::CurrentAttributes
    # @return [Admin::User]
    attribute :admin_user
  end
end

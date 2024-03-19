# frozen_string_literal: true

require "active_support/configurable"
require "active_support/core_ext/numeric"

module Koi
  class Config
    include ActiveSupport::Configurable

    config_accessor(:resource_name_candidates) { %i[title name] }

    config_accessor(:image_size_limit) { 10.megabytes }

    config_accessor(:admin_stylesheet) { "koi/admin" }
  end
end

# frozen_string_literal: true

require "active_support/configurable"

module Koi
  class Config
    include ActiveSupport::Configurable

    config_accessor(:resource_name_candidates) { %i[title name] }
  end
end

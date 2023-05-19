# frozen_string_literal: true

require "active_support/core_ext/integer/time"

module Koi
  module Caching
    # Caching Enabled
    mattr_accessor :enabled
    @@enabled = true

    # Cache Expires in
    mattr_accessor :expires_in
    @@expires_in = 60.minutes
  end
end

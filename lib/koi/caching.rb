# frozen_string_literal: true

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

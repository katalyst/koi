module Koi
  module Caching
    # Caching Enabled
    mattr_accessor :enabled
    @@enabled = true

    mattr_accessor :god_nav_tab_enabled
    @@god_nav_tab_enabled = false

    # Cache Expires in
    mattr_accessor :expires_in
    @@expires_in = 60.minutes
  end
end

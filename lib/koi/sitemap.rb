module Koi
  module Sitemap
    mattr_accessor :toggles
    @@toggles = true

    mattr_accessor :default_visible
    @@default_visible = []

    mattr_accessor :one_only
    @@one_only = false
  end
end

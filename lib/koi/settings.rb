module Koi
  module Settings
    # Settings for all collections
    mattr_accessor :collection
    @@collection = {}

    # Settings for all resources
    mattr_accessor :resource
    @@resource = {}
  end
end

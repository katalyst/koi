require 'active_support/core_ext/numeric/bytes'

module Koi
  module Asset
    # Image incase no icon cannot be found
    mattr_accessor :unknown_image
    @@unknown_image = '/assets/koi/asset/asset-unknown.png'

    # Default file upload size limit
    mattr_accessor :size_limit
    @@size_limit = 5.megabytes
  end
end

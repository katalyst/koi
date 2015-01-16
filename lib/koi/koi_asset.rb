require 'active_support/core_ext/numeric/bytes'

module Koi
  module KoiAsset
    # Image incase no icon cannot be found
    mattr_accessor :unknown_image
    @@unknown_image = 'koi/application/icon-file-unknown.png'

    # Default file upload size limit
    mattr_accessor :size_limit
    @@size_limit = 5.megabytes
  end
end

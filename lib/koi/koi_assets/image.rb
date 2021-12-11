# frozen_string_literal: true

module Koi
  module KoiAsset
    module Image
      # Default Image sizes for asset manager
      mattr_accessor :sizes
      @@sizes = [
        { width:    "600", title: "600 pixels wide" },
        { width:    "500", title: "500 pixels wide" },
        { width:    "400", title: "400 pixels wide" },
        { width:    "300", title: "300 pixels wide" },
        { width:    "200", title: "200 pixels wide" },
        { width:    "100", title: "100 pixels wide" },
      ]

      # Image file upload size limit
      mattr_accessor :size_limit
      @@size_limit = 5.megabytes

      # Image extensions allowed for upload
      mattr_accessor :extensions
      @@extensions = %i[gif jpg jpeg png]

      # Image mime types allowed for upload
      mattr_accessor :mime_types
      @@mime_types = %w[image/jpg image/jpeg image/png image/gif]
    end
  end
end

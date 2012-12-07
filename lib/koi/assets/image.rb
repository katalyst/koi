module Koi
  module Asset
    module Image
      # Default Image sizes for asset manager
      mattr_accessor :sizes
      @@sizes = [
        { width:    '100%' , title: '1 / 1 (100%)' },
        { width:     '50%' , title: '1 / 2 (50%)'  },
        { width:     '20%' , title: '1 / 5 (20%)'  },
        { width:     '33%' , title: '1 / 3 (33%)'  },
        { width:     '25%' , title: '1 / 4 (25%)'  }
      ]

      # Image file upload size limit
      mattr_accessor :size_limit
      @@size_limit = 5.megabytes

      # Image extensions allowed for upload
      mattr_accessor :extensions
      @@extensions = [ :gif, :jpg, :jpeg, :png ]

      # Image mime types allowed for upload
      mattr_accessor :mime_types
      @@mime_types = %w(image/jpg image/jpeg image/png image/gif)
    end
  end
end

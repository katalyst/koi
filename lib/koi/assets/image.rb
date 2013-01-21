module Koi
  module Asset
    module Image
      # Default Image sizes for asset manager
      mattr_accessor :sizes
      @@sizes = [
        { width:    '950' , title: '950px wide' },
        { width:    '700' , title: '700px wide' },
        { width:    '450' , title: '450px wide' },
        { width:    '200' , title: '200px wide' }
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

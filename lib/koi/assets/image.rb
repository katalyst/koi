module Koi
  module Asset
    module Image
      # Default Image sizes for asset manager
      mattr_accessor :sizes
      @@sizes = [
        { :title => 'Original', :size => '' },
        { :title => '200 x 200px', :size => '200x200' }
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

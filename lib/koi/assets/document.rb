module Koi
  module Asset
    module Document
      # Document file upload size limit
      mattr_accessor :size_limit
      @@size_limit = 10.megabytes

      # Document extensions allowed for upload
      mattr_accessor :extensions
      @@extensions = [ :pdf, :doc, :docx, :xls, :xlsx, :ppt, :zip ] + Image.extensions

      # Document mime types allowed for upload
      mattr_accessor :mime_types
      @@mime_types = %w(application/pdf application/doc
                        application/docx application/xls
                        application/xlsx application/ppt application/zip) + Image.mime_types

      mattr_accessor :icons
      @@icons = {
                  'pdf'  => '/assets/koi/icon/file/pdf.png',
                  'doc'  => '/assets/koi/icon/file/doc.png',
                  'docx' => '/assets/koi/icon/file/doc.png',
                  'xls'  => '/assets/koi/icon/file/xls.png',
                  'xlsx' => '/assets/koi/icon/file/xls.png',
                  'ppt'  => '/assets/koi/icon/file/ppt.png',
                  'zip'  => '/assets/koi/icon/file/zip.png'
              }
    end
  end
end

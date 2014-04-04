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
      @@mime_types = %w(application/pdf
                        application/doc
                        application/docx
                        application/xls
                        application/xlsx
                        application/vnd.ms-excel
                        application/msword
                        application/ppt
                        application/zip) + Image.mime_types

      mattr_accessor :icons
      @@icons = {
                  'pdf'  => '/assets/koi/application/icon-file-pdf.png',
                  'doc'  => '/assets/koi/application/icon-file-doc.png',
                  'docx' => '/assets/koi/application/icon-file-doc.png',
                  'xls'  => '/assets/koi/application/icon-file-xls.png',
                  'xlsx' => '/assets/koi/application/icon-file-xls.png',
                  'ppt'  => '/assets/koi/application/icon-file-ppt.png',
                  'zip'  => '/assets/koi/application/icon-file-zip.png'
              }
    end
  end
end

module Koi
  module KoiAsset
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
                        application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
                        application/msword
                        application/vnd.openxmlformats-officedocument.wordprocessingml.document
                        application/ppt
                        application/vnd.ms-powerpoint
                        application/octet-stream
                        application/zip) + Image.mime_types

      mattr_accessor :icons
      @@icons = {
                  'pdf'  => 'koi/application/icon-file-pdf.png',
                  'doc'  => 'koi/application/icon-file-doc.png',
                  'docx' => 'koi/application/icon-file-doc.png',
                  'xls'  => 'koi/application/icon-file-xls.png',
                  'xlsx' => 'koi/application/icon-file-xls.png',
                  'ppt'  => 'koi/application/icon-file-ppt.png',
                  'pptx' => 'koi/application/icon-file-ppt.png',
                  'zip'  => 'koi/application/icon-file-zip.png',
                  'img'  => 'koi/application/icon-file-img.png'
              }
    end
  end
end

# ASSETS ###########################################################################################

KOI_ASSET_UNKNOWN_IMAGE = '/assets/admin/asset/asset-unknown.png'

KOI_ASSET_IMAGE_SIZES = [
  { :title => 'Original', :size => '' },
  { :title => '200 x 200px', :size => '200x200' }
]

KOI_ASSET_IMAGE_SIZE_LIMIT = 5.megabytes

KOI_ASSET_IMAGE_EXTENSIONS = [ :gif, :jpg, :jpeg, :png ]

KOI_ASSET_IMAGE_MIME_TYPES = %w(image/jpg image/jpeg image/png image/gif)

KOI_ASSET_DOCUMENT_SIZE_LIMIT = 10.megabytes

KOI_ASSET_DOCUMENT_EXTENSIONS = [ :pdf, :doc, :docx, :xls, :xlsx, :ppt, :zip ] + KOI_ASSET_IMAGE_EXTENSIONS

KOI_ASSET_DOCUMENT_MIME_TYPES = %w(application/pdf application/doc application/docx application/xls application/xlsx application/ppt application/zip)

KOI_ASSET_DOCUMENT_ICONS = {
  'pdf'  => '/assets/admin/icon/file/pdf.png',
  'doc'  => '/assets/admin/icon/file/doc.png',
  'docx' => '/assets/admin/icon/file/doc.png',
  'xls'  => '/assets/admin/icon/file/xls.png',
  'xlsx' => '/assets/admin/icon/file/xls.png',
  'ppt'  => '/assets/admin/icon/file/ppt.png',
  'zip'  => '/assets/admin/icon/file/zip.png'
}


module Koi::DocumentHelper

  def document_thumbnail(document, options={})
    ext = File.extname(document.data_name).gsub('.', '')
    return path_to_asset(Koi::KoiAsset::Document.icons[ext]) if Koi::KoiAsset::Document.icons.has_key?(ext)
    return path_to_asset(Koi::KoiAsset::Document.icons['img']) if Koi::KoiAsset::Image.extensions.include?(ext.to_sym)
    path_to_asset(Koi::KoiAsset.unknown_image)
  end
end

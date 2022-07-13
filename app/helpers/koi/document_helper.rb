# frozen_string_literal: true

module Koi
  module DocumentHelper
    def document_thumbnail(document, _options = {})
      ext = case document
            when Document
              document.data_name ? File.extname(document.data_name).gsub(".", "") : ""
            else
              document.ext
            end

      return path_to_asset(Koi::KoiAsset::Document.icons[ext]) if Koi::KoiAsset::Document.icons.key?(ext)
      return path_to_asset(Koi::KoiAsset::Document.icons["img"]) if Koi::KoiAsset::Image.extensions.include?(ext.to_sym)

      path_to_asset(Koi::KoiAsset.unknown_image)
    end
  end
end

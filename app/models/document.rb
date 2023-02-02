# frozen_string_literal: true

class Document < Asset
  has_crud paginate: false

  dragonfly_accessor :data, app: :file

  validates_size_of :data, maximum: Koi::KoiAsset::Document.size_limit
  validates_property :mime_type, of: :data,
                                 in: Koi::KoiAsset::Document.mime_types, case_sensitive: false

  crud.config do
    fields data: { type: :file, label: false }, tag_list: { type: :tags }
    config(:admin) { form fields: [:data] }
  end

  def thumbnail(_options = {})
    # FIXME: For some read mime_type take a long time to compute
    #        Using ext to make the document list faster
    ext = File.extname(data_name).gsub(".", "")
    return Koi::KoiAsset::Document.icons[ext] if Koi::KoiAsset::Document.icons.key?(ext)
    return Koi::KoiAsset::Document.icons["img"] if Koi::KoiAsset::Image.extensions.include?(ext.to_sym)

    Koi::KoiAsset.unknown_image
  end

  def url(*_args)
    "/#{self.class.to_s.tableize}/#{to_param}.#{data.ext}"
  end
end

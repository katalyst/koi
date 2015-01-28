class Document < Asset

  dragonfly_accessor :data, app: :file

  validates_size_of :data, maximum: Koi::KoiAsset::Document.size_limit
  validates_property :mime_type, of: :data,
    in: Koi::KoiAsset::Document.mime_types, case_sensitive: false

  def thumbnail(options={})
    # FIXME: For some read mime_type take a long time to compute
    #        Using ext to make the document list faster
    ext = File.extname(data_name).gsub('.', '')
    return Koi::KoiAsset::Document.icons[ext] if Koi::KoiAsset::Document.icons.has_key?(ext)
    return Koi::KoiAsset::Document.icons['img'] if Koi::KoiAsset::Image.extensions.include?(ext.to_sym)
    return Koi::KoiAsset.unknown_image
  end

  def url(*args)
    data.url
  end

end

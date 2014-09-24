class Document < Asset
  validates_size_of :data, maximum: Koi::KoiAsset::Document.size_limit
  validates_property :mime_type, of: :data,
    in: Koi::KoiAsset::Document.mime_types
end

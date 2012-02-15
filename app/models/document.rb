class Document < Asset
  validates_size_of :data, maximum: Koi::Asset::Document.size_limit
  validates_property :mime_type, of: :data,
    in: Koi::Asset::Document.mime_types
end

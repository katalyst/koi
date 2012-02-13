class Document < Asset
  validates_size_of :data, maximum: KOI_ASSET_DOCUMENT_SIZE_LIMIT
  validates_property :mime_type, of: :data,
    in: KOI_ASSET_DOCUMENT_MIME_TYPES + KOI_ASSET_IMAGE_MIME_TYPES
end


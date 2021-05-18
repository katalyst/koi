class Document < Asset

  has_crud paginate: false, settings: false

  dragonfly_accessor :data, app: :file

  validates_size_of :data, maximum: Koi::KoiAsset::Document.size_limit
  validates_property :mime_type, of: :data,
    in: Koi::KoiAsset::Document.mime_types, case_sensitive: false

  crud.config do
    fields data: { type: :file, label: false }, tag_list: { type: :tags }
    config(:admin) { form fields: [:data] }
  end

  def url(*args)
    data.url
  end

end

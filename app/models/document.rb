class Document < Asset

  has_crud paginate: false, settings: false

  dragonfly_accessor :data, app: :file if Koi::KoiAsset.use_dragonfly?

  if Koi::KoiAsset.use_dragonfly? && !Koi::KoiAsset.use_active_storage?
    # if we're using dragonfly and not active storage, validate dragonfly attributes on create
    validates_size_of :data, maximum: Koi::KoiAsset::Document.size_limit
  end

  crud.config do
    fields data: { type: :file, label: false }, tag_list: { type: :tags }
    config(:admin) { form fields: [:data] }
  end

  def url(*args)
    Rails.application.routes.url_helpers.document_url(self)
  end

  def data_url(*args)
    url(*args)
  end
end

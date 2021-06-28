class Image < Asset
  has_crud paginate: false, settings: false

  dragonfly_accessor :data, app: :image if Koi::KoiAsset.use_dragonfly?

  if Koi::KoiAsset.use_dragonfly? && !Koi::KoiAsset.use_active_storage?
    # if we're using dragonfly and not active storage, validate dragonfly attributes on create
    validates_size_of :data, maximum: Koi::KoiAsset::Image.size_limit
  end

  crud.config do
    fields data: { type: :file, label: false }, tag_list: { type: :tags }
    config(:admin) { form fields: [:data] }
  end

  def html_options
    { width: width, height: height }
  end

  delegate :width, :height, to: :storage_data

  def title_options
    "#{ width } x #{ height }px"
  end

  def dragonfly_options
    "#{ width }x#{ height }"
  end

  def thumbnail(options = {})
    url(options)
  end

  def url(*args)
    opt  = args.extract_options!
    size = opt[:size]
    size = args.shift if String === args.first
    Rails.application.routes.url_helpers.image_url(self, size: size)
  end

  def data_url(*args)
    url(*args)
  end

  private

  def storage_data
    if Koi::KoiAsset.use_active_storage? && attachment.present?
      attachment
    elsif Koi::KoiAsset.use_dragonfly?
      data
    end
  end
end

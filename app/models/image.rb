class Image < Asset
  validates_size_of :data, maximum: KOI_ASSET_IMAGE_SIZE_LIMIT
  validates_property :mime_type, of: :data, in: KOI_ASSET_IMAGE_MIME_TYPES

  def html_options
    { width: width, height: height }
  end

  delegate :width, :height, to: :data

  def title_options
    "#{ width } x #{ height }px"
  end

  def dragonfly_options
    "#{ width }x#{ height }"
  end

end


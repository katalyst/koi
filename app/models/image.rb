class Image < Asset
  validates_size_of :data, maximum: Koi::Asset::Image.size_limit
  validates_property :mime_type, of: :data, in: Koi::Asset::Image.mime_types

  friendly_id :slug, use: [:slugged, :finders, :history]

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

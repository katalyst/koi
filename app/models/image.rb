class Image < Asset

  dragonfly_accessor :data, app: :image

  validates_size_of :data, maximum: Koi::KoiAsset::Image.size_limit
  validates_property :mime_type, of: :data,
    in: Koi::KoiAsset::Image.mime_types, case_sensitive: false

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

  def thumbnail(options={})
    url options
  end

  def url(*args)
    opt  = args.extract_options!
    size = opt[:size]
    size = args.shift if String === args.first
    path = "/#{ self.class.to_s.tableize }/#{ to_param }.#{ data.ext }"
    return path if size.blank?
    width, height = size.match(/([0-9]*)x([0-9]*)/).to_a.drop 1
    return "#{ path }/?width=#{ width }&height=#{ height }"
  end

end

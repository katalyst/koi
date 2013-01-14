class Asset < ActiveRecord::Base
  has_crud paginate: false, settings: false

  scoped_search :on => [:data_name]

  scope :unassociated, where(attributable_type: nil)

  acts_as_taggable

  belongs_to :attributable, polymorphic: true

  image_accessor :data
  validates_presence_of :data
  validates_property :mime_type, of: :data,
    in: Koi::Asset::Document.mime_types

  crud.config do
    fields data: { type: :file, label: false }, tag_list: { type: :tags }
    config(:admin) { form fields: [:data] }
  end

  def titleize
    data.name.sub /\.\w+$/, ''
  end

  def thumbnail(options={})
    # FIXME: For some read mime_type take a long time to compute
    #        Using ext to make the document list faster
    ext = File.extname(data_name).gsub('.', '')
    return Koi::Asset::Document.icons[ext] if Koi::Asset::Document.icons.has_key?(ext)
    return url options if Koi::Asset::Image.extensions.include?(ext.to_sym)
    return Koi::Asset.unknown_image
  end

  def url(*args)
    opt  = args.extract_options!
    size = opt[:size]
    size = args.shift if String === args.first
    path = "/#{ self.class.to_s.tableize }/#{ to_param }.#{ data.format }"
    return path if size.blank?
    width, height = size.match(/([0-9]*)x([0-9]*)/).to_a.drop 1
    return "#{ path }/?width=#{ width }&height=#{ height }"
  end

end

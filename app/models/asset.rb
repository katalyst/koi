class Asset < ActiveRecord::Base
  has_crud paginate: false

  scoped_search :on => [:data_name]

  acts_as_taggable

  belongs_to :attributable, polymorphic: true

  image_accessor :data
  validates_presence_of :data
  validates_property :mime_type, of: :data,
    in: KOI_ASSET_IMAGE_MIME_TYPES + KOI_ASSET_DOCUMENT_MIME_TYPES

  crud.config do
    fields data: { type: :file, label: false }, tag_list: { type: :tags }
    config(:admin) { form fields: [:data] }
  end

  def thumbnail(options={})
    # FIXME: For some read mime_type take a long time to compute
    #        Using ext to make the document list faster
    ext = File.extname(data_name).gsub('.', '')
    return KOI_ASSET_DOCUMENT_ICONS[ext] if KOI_ASSET_DOCUMENT_ICONS.has_key?(ext)
    return url options if KOI_ASSET_IMAGE_EXTENSIONS.include?(ext.to_sym)
    return KOI_ASSET_UNKNOWN_IMAGE
  end

  def url(*args)
    opt = args.extract_options!
    return data.url if opt[:size].blank?
    return data.thumb(opt[:size]).url
  end

end


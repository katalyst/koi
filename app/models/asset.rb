class Asset < ActiveRecord::Base
  include Koi::Model

  has_crud paginate: false, settings: false

  dragonfly_accessor :data, app: :file if Koi::KoiAsset.use_dragonfly?
  has_one_attached :attachment if Koi::KoiAsset.use_active_storage?

  scoped_search on: [:data_name]

  scope :unassociated, -> { where("attributable_type IS NULL OR attributable_type = ''") }
  scope :search_data, -> query { where("data_name LIKE ?", "%#{query}%") }
  scope :newest_first, -> { order(created_at: :desc) }

  acts_as_ordered_taggable

  belongs_to :attributable, polymorphic: true, optional: true

  if Koi::KoiAsset.use_dragonfly? && !Koi::KoiAsset.use_active_storage?
    # if we're using dragonfly and not active storage, validate dragonfly attributes on create
    validates_presence_of :data
    validates_property :mime_type,
                       of: :data,
                       in: Koi::KoiAsset::Document.mime_types, case_sensitive: false
  end

  crud.config do
    fields data: { type: :file, label: false }, tag_list: { type: :tags }
    config(:admin) { form fields: [:data] }
  end

  def titleize
    filename.sub /\.\w+$/, ''
  end

  def to_s
    filename || "Asset"
  end

  def filename
    if attachment
      attachment.filename
    elsif Koi::KoiAsset.use_dragonfly? && data
      File.basename data.name, File.extname(data.name)
    end
  end
end

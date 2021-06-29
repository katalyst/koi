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

  if Koi::KoiAsset.use_active_storage?
    alias_method :storage_data=, :attachment=
    alias_method :storage_data, :attachment
  elsif Koi::KoiAsset.use_dragonfly?
    alias_method :storage_data=, :file=
    alias_method :storage_data, :file
  end

  validates_presence_of :storage_data

  if Koi::KoiAsset.use_dragonfly? && !Koi::KoiAsset.use_active_storage?
    # if we're using dragonfly and not active storage, validate dragonfly mime type
    validates_property :mime_type,
                       of: :data,
                       in: Koi::KoiAsset::Document.mime_types, case_sensitive: false
  end

  crud.config do
    fields storage_data: { type: :file, label: false }, tag_list: { type: :tags }
    config(:admin) { form fields: [:storage_data] }
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

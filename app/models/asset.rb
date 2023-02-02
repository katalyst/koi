# frozen_string_literal: true

class Asset < ApplicationRecord
  has_crud paginate: false

  dragonfly_accessor :data, app: :file

  scoped_search on: [:data_name]

  scope :unassociated, -> { where("attributable_type IS NULL OR attributable_type = ''") }
  scope :search_data,  ->(query) { where("data_name LIKE ?", "%#{query}%") }
  scope :newest_first, -> { order(created_at: :desc) }

  acts_as_ordered_taggable

  belongs_to :attributable, polymorphic: true, optional: true

  validates_presence_of :data
  validates_property :mime_type, of: :data,
                                 in: Koi::KoiAsset::Document.mime_types, case_sensitive: false

  crud.config do
    fields data: { type: :file, label: false }, tag_list: { type: :tags }
    config(:admin) { form fields: [:data] }
  end

  def titleize
    data.name.sub(/\.\w+$/, "")
  end

  def to_s
    if data
      File.basename data.name, File.extname(data.name)
    else
      "Asset"
    end
  end
end

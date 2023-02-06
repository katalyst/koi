# frozen_string_literal: true

class Asset < ApplicationRecord
  include FriendlyId

  friendly_id :to_s, use: %i[slugged finders history]

  dragonfly_accessor :data, app: :file

  scoped_search on: [:data_name]

  scope :unassociated, -> { where("attributable_type IS NULL OR attributable_type = ''") }
  scope :search_data,  ->(query) { where("data_name LIKE ?", "%#{query}%") }
  scope :newest_first, -> { order(created_at: :desc) }

  belongs_to :attributable, polymorphic: true, optional: true

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

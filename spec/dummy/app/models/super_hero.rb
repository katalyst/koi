# frozen_string_literal: true

class SuperHero < ApplicationRecord
  has_crud ajaxable:   true,
           searchable: %i[id name gender powers],
           orderable:  false,
           paginate:   false

  # FIXME: Refactored from has
  has_many :images, as: :attributable
  accepts_nested_attributes_for :images, allow_destroy: true

  dragonfly_accessor :image
  dragonfly_accessor :file
  serialize :powers, Array

  scope :alphabetical, -> { order("name DESC") }

  default_scope -> { alphabetical }

  GENDERS = %w[Male Female Robot].freeze
  POWERS = ["X-RAY VISION", "REGENERATION", "TOTAL RECALL", "TELEPORTATION",
            "WEATHER CONTROL", "FORCE FIELDS", "UNDERWATER BREATHING", "SUPER STRENGTH"].freeze

  validates :name, :description, presence: true

  crud.config do
    map image_uid: :image
    map file_uid:  :file

    fields gender:             { type: :select, data: GENDERS, size: :small },
           is_alive:           { type: :boolean },
           url:                { type: :disabled, wrapper_data: { show: "super_hero_is_alive" } },
           last_location_seen: { type: :latlng },
           powers:             { type: :check_boxes, data: POWERS },
           images:             { type: :inline },
           published_at:       { type: :date, size: :small, datepicker: { dateformat: "dd M yy", maxdate: "0" } },
           telephone:          { type: :readonly }

    index  fields: %i[name description published_at gender is_alive url
                      telephone]

    form   fields: %i[name description published_at gender is_alive url
                      telephone]

    config :admin do
      actions only: %i[show edit new destroy index]
      csv     except: %i[image_name file_name]
      index   fields: %i[id name image file]
      # order:  { name: :asc }
      form    fields: %i[name description published_at gender is_alive url
                         last_location_seen telephone image file
                         image_upload document_upload powers]
      show    fields: %i[name description published_at gender is_alive url
                         last_location_seen telephone image file
                         image_upload_id document_upload_id powers]
      reportable true
      charts [{
        span:     :created_at,
        field:    :id,
        strategy: :count,
        colour:   "#f60",
        name:     "New Super Heros Created",
        renderer: "bar",
      }, {
        span:     :created_at,
        field:    :id,
        strategy: :sum,
        colour:   "black",
        name:     "Sum of Super Heros Created IDs with name Bob",
        scope:    :bob,
      }]

      overviews [{
        span:   :created_at,
        name:   "Total Super Heros Created",
        period: :all_time,
      }, {
        field:  :id,
        name:   "Super Heros Created in the Last Month",
        prefix: "$",
      }, {
        period:  :weekly,
        field:   :id,
        name:    "Super Heros Created in the Last Week",
        postfix: "%",
      }]
    end
  end

  def self.bob
    where(name: "Bob")
  end

  def self.except_these_groups
    %w[Tags SEO]
  end

  def except_these_groups
    ["SEO"]
  end

  def cropped_image_upload
    if image_upload_crop.blank?
      Asset.find(image_upload_id).data
    else
      Asset.find(image_upload_id).data.thumb(image_upload_crop)
    end
  rescue ActiveRecord::RecordNotFound
    ""
  end

  def to_s
    name
  end
end

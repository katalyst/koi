# frozen_string_literal: true

class Setting < Translation
  after_initialize :derive_data_source
  before_validation :set_prefix_if_blank

  acts_as_ordered_taggable

  COLLECTION_TYPES = %w[check_boxes radio select tags].freeze
  FIELD_TYPES      = Translation::FIELD_TYPES.merge(
    "Select"      => "select",
    "Radio"       => "radio",
    "Check Boxes" => "check_boxes",
    "File"        => "file",
    "Image"       => "image",
    "Tags"        => "tags",
  ).freeze

  dragonfly_accessor :file
  serialize :serialized_value, type: Array, coder: Psych

  has_crud paginate: false, searchable: false,
           orderable: false, settings: false

  validates :locale, :label, :key, :field_type,
            :prefix, :role, presence: true

  validates_uniqueness_of :key, scope: :prefix

  attr_accessor :data_source

  crud.config do
    fields field_type: { type: :select, data: FIELD_TYPES },
           value:      { type: :dynamic },
           prefix:     { type: :hidden },
           label:      { writable_method: :god? },
           role:       { type: :select, data: AdminUser::ROLES },
           is_proc:    { type: :boolean },
           images:     { type: :inline }

    config :admin do
      index fields: [:label],
            title:  "Settings"
      form  fields: %i[label field_type prefix key value hint role is_proc images],
            title:  { new: "Create new setting", edit: "Edit setting" }
    end
  end

  def derive_data_source(collection: false)
    if COLLECTION_TYPES.include? field_type
      self.data_source = if collection
                           ::Koi::Settings.collection[key.to_sym][:data_source]
                         else
                           ::Koi::Settings.resource[key.to_sym][:data_source]
                         end
      raise NoMethodError unless data_source
    end
  rescue NoMethodError
    error = "Problem loading data source for '#{key}' setting.
Please check config/initializers/koi.rb correctly defines the data_source attribute for #{key}."
    Rails.logger.error error
  end

  dragonfly_accessor :file
  alias document file
  alias document= file=
  alias image file
  alias image= file=

  private

  def set_prefix_if_blank
    self.prefix = "site" if prefix.blank? && key.include?("site")
  end
end

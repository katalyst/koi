class Translation < ActiveRecord::Base

  has_crud paginate: false, searchable: false, orderable: false, settings: false

  has :many, attributed: :images, orderable: true

  # images_attributes= filters out invalid images in advance,
  # so we don't have to worry about validation
  #
  alias_method :was_images_attributes=, :images_attributes=

  def images_attributes= params
    params.values.each { |hash| hash[:_destroy] = true if hash[:data].blank? }
    self.was_images_attributes = params
  end

  # _destroy is the mark-of-death, used in a similar way to nested_fields
  # TODO: bypass validations if _destroy is checked
  #
  attr_reader :_destroy
  
  def _destroy= value
    @_destroy = ActiveRecord::ConnectionAdapters::Column.value_to_boolean value
  end

  after_save :delete, if: :_destroy

  validates :locale, :label, :key, :field_type, :role, presence: true

  # validates :value, presence: true, unless: Proc.new{ |r| r.field_type.eql?("images") }

  validates_uniqueness_of :key, scope: :prefix

  before_validation :set_default_values

  default_scope order("`key` ASC")

  FieldTypes = {
                 "String"    => "string",
                 "Boolean"   => "boolean",
                 "Text"      => "text",
                 "Rich Text" => "rich_text",
                 "Images"    => "images"
               }

  crud.config do
    fields field_type: { type: :select, data: FieldTypes },
           value:      { type: :dynamic },
           role:       { type: :select, data: Admin::ROLES }
    config :admin do
      index fields: [:label],
            title: "Settings"
      form  fields: [:label, :field_type, :key, :value, :hint, :role, :is_proc],
            title: { new: "Create new setting", edit: "Edit setting" }
    end
  end

  def value
    field_type.eql?("images") ? images : read_attribute(:value)
  end

private

  def set_default_values
    write_attribute :field_type, 'string'  if field_type.blank?
    write_attribute :label, key.titleize   if label.blank? && key.present?
    write_attribute :key, label.underscore if key.blank? && label.present?
    write_attribute :role, Admin.god       if role.blank?
  end

end
class << Translation

  def non_prefixed
    where "translations.prefix IS NULL OR translations.prefix = ''"
  end

  def globals
    non_prefixed
  end

  def admin
    where role: 'Admin'
  end

end

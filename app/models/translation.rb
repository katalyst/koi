class Translation < ActiveRecord::Base

  has_crud paginate: false, searchable: false,
           orderable: false, settings: false

  has :many, attributed: :images, orderable: true

  after_save :reset_memory_store_cache

  validates :locale, :label, :key, :field_type,
            :role, presence: true

  validates_uniqueness_of :key, scope: :prefix

  before_validation :set_default_values

  scope :non_prefixed, where("prefix IS NULL OR prefix = ''")

  FieldTypes = {
                 "String"    => "string",
                 "Boolean"   => "boolean",
                 "Text"      => "text",
                 "Rich Text" => "rich_text",
                 "Images"    => "images"
               }

  scope :admin, where(role: "Admin")

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
    self.role ||= Admin.god
  end

  def reset_memory_store_cache
    I18n.cache_store = nil
    I18n.cache_store = ActiveSupport::Cache.lookup_store(:memory_store)
  end

end

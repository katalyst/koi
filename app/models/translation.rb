class Translation < ActiveRecord::Base
  has_crud paginate: false, searchable: false,
           orderable: false, settings: false

  validates :locale, :label, :key, :value, :field_type,
            :role, presence: true

  validates_uniqueness_of :key, scope: :prefix

  before_validation :set_default_values

  default_scope order("`key` ASC")
  scope :non_prefixed, where("prefix IS NULL OR prefix = ''")

  FieldTypes = {
                 "String"    => "string",
                 "Boolean"   => "boolean",
                 "Text"      => "text",
                 "Rich Text" => "rich_text"
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

  private

  def set_default_values
    self.role ||= Admin.god
  end
end

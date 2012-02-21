class Translation < ActiveRecord::Base
  has_crud paginate: false, searchable: false, orderable: false

  validates :locale, :label, :key, :value, :field_type, :role, presence: true
  validates :key, :uniqueness => true

  default_scope order("`key` ASC")

  FieldTypes = {
                 "String"    => "string",
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
end

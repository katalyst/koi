class Setting < Translation
  has_crud paginate: false, searchable: false, orderable: false

  validates :locale, :label, :key, :value, :field_type,
            :prefix, :role, presence: true

  validates_uniqueness_of :key, scope: :prefix, allow_blank: true

  default_scope order("`key` ASC")

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
           prefix:     { type: :hidden },
           role:       { type: :select, data: Admin::ROLES }
    config :admin do
      index fields: [:label],
            title: "Settings"
      form  fields: [:label, :field_type, :prefix, :key, :value, :hint, :role, :is_proc],
            title: { new: "Create new setting", edit: "Edit setting" }
    end
  end
end

class Setting < Translation
  has_crud paginate: false, searchable: false, orderable: false

  validates :locale, :label, :key, :field_type,
            :prefix, :role, presence: true

  validates_uniqueness_of :key, scope: :prefix

  crud.config do
    fields field_type: { type: :select, data: FieldTypes },
           value:      { type: :dynamic },
           prefix:     { type: :hidden },
           role:       { type: :select, data: Admin::ROLES }
    config :admin do
      index fields: [:label],
            title: "Settings"
      form  fields: [:label, :field_type, :prefix, :key, :value, :hint, :role, :is_proc, :images],
            title: { new: "Create new setting", edit: "Edit setting" }
    end
  end
end

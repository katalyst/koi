class Setting < Translation
  has_crud paginate: false, searchable: false, orderable: false, settings: false

  validates :locale, :label, :key, :field_type, :role, presence: true # , :prefix

  validates_uniqueness_of :key, scope: :prefix

  crud.config do
    fields field_type: { type: :select, data: FieldTypes },
           value:      { type: :dynamic },
           prefix:     { type: :hidden },
           label:      { writable_method: :god? },
           role:       { type: :select, data: Admin::ROLES },
           is_proc:    { type: :boolean }
    config :admin do
      index fields: [:label],
            title: "Settings"
      form  fields: [:label, :key, :field_type, :prefix, :value, :hint, :role, :is_proc, :images],
            title: { new: "Create new setting", edit: "Edit setting" }
    end
  end
end

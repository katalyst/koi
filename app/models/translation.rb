class Translation < ActiveRecord::Base
  has_crud paginate: false, searchable: false, orderable: false

  validates :locale, :label, :key, :value, :field_type, presence: true
  validates :key, :uniqueness => true

  default_scope order("`key` ASC")

  FieldTypes = {
                 "String"    => "string",
                 "Text"      => "text",
                 "Rich Text" => "rich_text"
               }

  crud.config do
    fields field_type: { type: :select, data: FieldTypes },
           value:      { type: :dynamic }

    config :admin do
      index fields: [:label],
            title: "Settings"
      form  fields: [:label, :field_type, :key, :value, :hint, :is_proc],
            title: { new: "Create new setting", edit: "Edit setting" }
    end
  end
end

class KidHero < SuperHero
  has_crud has_managed_assets: true

  managed_image :managed_image
  managed_document :managed_document

  crud.config do
    fields gender:             { type: :select, data: Gender },
           powers:             { type: :check_boxes, data: Powers },
           managed_image:      { type: :managed_image },
           managed_document:   { type: :managed_document }

    index fields: [:name, :gender]
    form  fields: [:name, :gender]

    config :admin do
      index fields: [:name, :gender]
      form  fields: [
        :name,
        :description,
        :powers,
        :gender,
        :managed_image,
        :managed_document,
      ]
    end
  end

end

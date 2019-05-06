class KidHero < SuperHero

  has_crud

  crud.config do
    fields gender: { type: :select, data: Gender },
           powers: { type: :check_boxes, data: Powers }

    index fields: [:name, :gender]
    form  fields: [:name, :gender]

    config :admin do
      index fields: [:name, :gender]
      form  fields: [:name, :description, :gender, :powers]
    end
  end

end

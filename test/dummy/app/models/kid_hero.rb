class KidHero < SuperHero

  has_crud

  crud.config do
    fields gender: { type: :select, data: Gender }

    index fields: [:name, :gender]
    form  fields: [:name, :gender]

    config :admin do
      index fields: [:name, :gender]
      form  fields: [:name, :description, :gender]
    end
  end

end

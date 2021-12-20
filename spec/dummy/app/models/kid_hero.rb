# frozen_string_literal: true

class KidHero < SuperHero
  has_crud

  crud.config do
    fields gender: { type: :select, data: GENDERS }

    index fields: %i[name gender]
    form  fields: %i[name gender]

    config :admin do
      index fields: %i[name gender]
      form  fields: %i[name description gender]
    end
  end
end

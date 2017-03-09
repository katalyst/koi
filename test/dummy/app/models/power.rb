class Power < ActiveRecord::Base

  has_crud

  has_and_belongs_to_many :super_heros

  crud.config do
    fields   title: { type: :default }

    config :admin do
      actions only:  [:index, :show, :new, :edit]
      index fields: [:title],
            order:  { created_at: :desc }
      form  fields: [:title]
      csv   fields: [:title]
    end
  end

end

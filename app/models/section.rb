class Section < ActiveRecord::Base
  has_crud paginate: false, navigation: false

  belongs_to :attributable, polymorphic: true

  def to_s
    title
  end

  crud.config do
    config :admin do
      form fields: [:title, :description]
    end
  end
end

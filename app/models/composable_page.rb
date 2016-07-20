class ComposablePage < Page

  include Composable

  has_crud paginate: false, navigation: true,
           settings: true

  validates_presence_of :title

  def titleize
    title
  end

  def to_s
    title
  end

  crud.config do

    fields composable_contents: { type: :inline }
    
    config :admin do
      index   fields: [:id, :title]
      form    fields: [:title, :composable_contents]
    end
  end

end

class Page < ActiveRecord::Base
  has_crud paginate: false, navigation: true

  validates_presence_of :title

  def titleize
    title
  end

  def to_s
    title
  end

  crud.config do
    actions only: [:index, :show]
    hide false
    title collection: "Pages"
    config :admin do
      actions except: [:new]
      index   fields: [:id, :title]
      form    except: [:type]
    end
  end
end

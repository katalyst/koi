class FriendlyIdSlug < ActiveRecord::Base
  include Koi::Model

  has_crud ajaxable: true, slugged: false

  crud.config do
    config :admin do
      index fields: [:slug, :sluggable_id, :sluggable_type]
      form fields: [:slug, :sluggable_id, :sluggable_type]
    end
  end

  def to_s
    "URL for #{sluggable_type} - #{sluggable_id}"
  end

end

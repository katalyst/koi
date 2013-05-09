class FriendlyIdSlug < ActiveRecord::Base

  has_crud ajaxable: true

  crud.config do
    config :admin do
      index fields: [:slug, :sluggable_id, :sluggable_type]
    end
  end

end

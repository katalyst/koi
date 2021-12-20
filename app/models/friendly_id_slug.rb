# frozen_string_literal: true

class FriendlyIdSlug < ApplicationRecord
  has_crud ajaxable: true, slugged: false

  crud.config do
    config :admin do
      index fields: %i[slug sluggable_id sluggable_type]
      form fields: %i[slug sluggable_id sluggable_type]
    end
  end

  def to_s
    "URL for #{sluggable_type} - #{sluggable_id}"
  end
end

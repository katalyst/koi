class SuperHero < ActiveRecord::Base
  has_crud ajaxable: true,
           searchable: [:id, :name, :gender, :powers],
           orderable: false, settings: true

  has :many, attributed: :images, orderable: true

  image_accessor :image
  file_accessor  :file
  serialize :powers, Array

  Gender = ["Male", "Female", "Robot"]
  Powers = ["X-RAY VISION", "REGENERATION", "TOTAL RECALL", "TELEPORTATION",
            "WEATHER CONTROL", "FORCE FIELDS", "UNDERWATER BREATHING", "SUPER STRENGTH"]

  validates :name, :description, presence: true

  crud.config do
    map image_uid: :image
    map file_uid:  :file

    fields image:    { type: :image },
           file:     { type: :file  },
           gender:   { type: :select, data: Gender },
           is_alive: { type: :radio },
           powers:   { type: :check_boxes, data: Powers },
           published_at: { type: :date }

    form   fields: [:name, :description, :published_at, :gender, :is_alive, :url,
                    :telephone]

    config :admin do
      index   fields: [:name]
      form    fields: [:name, :description, :published_at, :gender, :is_alive, :url,
                       :telephone, :image, :file, :powers, :images]
    end
  end

  def titleize
    name
  end

  alias :to_s :titleize
end

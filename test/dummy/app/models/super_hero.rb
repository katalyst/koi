class SuperHero < ActiveRecord::Base

  has_crud ajaxable: true,
           searchable: [:id, :name, :gender, :powers],
           orderable: false, settings: true,
           paginate: false

  # FIXME: Refactored from has
  has_many :images, as: :attributable
  accepts_nested_attributes_for :images, allow_destroy: true

  dragonfly_accessor :image
  dragonfly_accessor  :file
  serialize :powers, Array

  scope :alphabetical, -> { order("name DESC") }

  default_scope -> { alphabetical }

  Gender = ["Male", "Female", "Robot"]
  Powers = ["X-RAY VISION", "REGENERATION", "TOTAL RECALL", "TELEPORTATION",
            "WEATHER CONTROL", "FORCE FIELDS", "UNDERWATER BREATHING", "SUPER STRENGTH"]

  validates :name, :description, presence: true

  crud.config do
    map image_uid: :image
    map file_uid:  :file

    fields image:          { type: :image },
           file:           { type: :file, droppable: true  },
           gender:         { type: :select, data: Gender },
           is_alive:       { type: :boolean },
           powers:         { type: :check_boxes, data: Powers },
           images:         { type: :inline },
           published_at:   { type: :datetime }

    form   fields: [:name, :description, :published_at, :gender, :is_alive, :url,
                    :telephone]

    config :admin do
      exportable true
      csv     except: [:image_name, :file_name]
      index   fields: [:id, :name, :image, :file]
              # order:  { name: :asc }
      form    fields: [:name, :description, :published_at, :gender, :is_alive, :url,
                       :telephone, :image, :file, :powers]
      reportable true
      charts [{
        span:     :created_at,
        field:    :id,
        strategy: :count,
        colour:   '#f60',
        name:     'New Super Heros Created',
        renderer: 'bar'
      },{
        span:     :created_at,
        field:    :id,
        strategy: :sum,
        colour:   'black',
        name:     'Sum of Super Heros Created IDs with name Bob',
        scope:    :bob
      }]

      overviews [{
        span:     :created_at,
        name:     'Total Super Heros Created',
        period:   :all_time
      },{
        field:    :id,
        name:     'Super Heros Created in the Last Month',
        prefix:   '$'
      }, {
        period:   :weekly,
        field:    :id,
        name:     'Super Heros Created in the Last Week',
        postfix:  '%'
      }]
    end
  end

  def self.bob
    where(name: 'Bob')
  end

  def self.except_these_groups
    ["Tags", "SEO"]
  end

  def except_these_groups
    ["SEO"]
  end

  def to_s
    name
  end

end

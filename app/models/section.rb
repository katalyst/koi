class Section < ActiveRecord::Base
  has_crud paginate: false, navigation: false

  attr_accessible :heading, :description

  belongs_to :attributable, polymorphic: true

  def to_s
    heading
  end
end

class Page < ActiveRecord::Base
  has_crud :paginate => false, navigation: true

  def self.to_s
    "Overwritten Page Model"
  end
end

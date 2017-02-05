module Composable
  extend ActiveSupport::Concern
  included do

    has_many :composable_contents, dependent: :destroy, as: :composable 
    accepts_nested_attributes_for :composable_contents, allow_destroy: true

  end
end
class NavigationLink < ApplicationRecord
  include Navigation::OrdinalTree::Item
  attr_accessor :index, :depth

  attr_reader :_open
  alias_method :open?, :_open

  belongs_to :navigation_menu

  validates :title, presence: true

  scope :visible, -> { where(visible: true) }

  def _open=(value)
    @_open = case value
             when true, false
               value
             when "1"
               true
             else
               false
             end
  end
end

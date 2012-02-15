class ModuleNavItem < NavItem
  validates :title, :url, :parent, presence: true

  def is_what?
    "module"
  end

  def self.title
    "Module"
  end
end


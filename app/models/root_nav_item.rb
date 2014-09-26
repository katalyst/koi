class RootNavItem < NavItem
  validates :title, presence: true

  def self.root
    super || RootNavItem.create!({ title: "Home", url: "/", key: "home" }, without_protection: true)
  end

  def is_what?
    "home"
  end

  def self.title
    "Root"
  end

  def draggable?
    false
  end
end

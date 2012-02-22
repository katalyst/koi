class ResourceNavItem < NavItem
  belongs_to :navigable, :polymorphic => true

  validates :title, :parent, :url, :admin_url, presence: true

  def is_what?
    "page"
  end

  def title
    read_attribute(:title) || "Title #{id}"
  end
end

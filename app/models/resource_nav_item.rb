class ResourceNavItem < NavItem
  belongs_to :navigable, :polymorphic => true

  validates :title, :parent, :url, :admin_url, presence: true

  def is_what?
    "page"
  end

  def title
    write_attribute :title, navigable.try((TITLE & navigable.methods).first) and save if read_attribute(:title).blank?
    read_attribute :title
  end

  TITLE = [:title, :name, :heading, :to_s]

end

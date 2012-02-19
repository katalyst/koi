class FolderNavItem < NavItem
  validates :title, :parent, presence: true

  def is_what?
    "folder"
  end

  def draggable?
    parent.eql?(root) ? false : true
  end

  def self.title
    "Folder"
  end

  def url
    return "#" if descendants.empty?
    descend = descendants.keep_if { |c| !c.is_hidden }
    descend.first.url unless descend.empty?
  end
end


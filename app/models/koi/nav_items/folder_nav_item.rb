module Koi
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
  end
end

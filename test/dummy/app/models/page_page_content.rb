class PagePageContent < ActiveRecord::Base
  has_crud

  belongs_to :page
  belongs_to :page_content

end


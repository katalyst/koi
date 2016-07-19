class PageContent < ActiveRecord::Base

  has_crud :orderable => true

  has_many :page_page_contents
  has_one :page, through: :page_page_contents

  validates :content_type, presence: true

  dragonfly_accessor :file

  scope :active, -> { where(active: true) }

  ContentTypes = [
    "Heading",
    "Text",
    "Quote",
    "WYSIWG",
    "File",
    "Gallery"
  ]

  delegate :type, to: :content_type

  crud.config do
    fields active:          { type: :boolean },
           content_type:    { type: :select, data: ContentTypes },
           # file_id:         { type: :uploader, types: "pdf, xls, xlsx, doc, docx", max_size: 10 },
           file:            { type: :image },
           string:          { wrapper_data: { show: "content_type", show_option: "Heading_&_Quote", show_type: "any", show_inline: "true" } }
    config :admin do
      form  fields: [:content_type, :string,  :text, :file, :file_id]
    end
  end

  def data
    if type.eql?("Heading") || 
       type.eql?("Quote") 
      string
    elsif type.eql?("Text") ||
          type.eql?("WYSIWYG")
      text
    end
  end

  def to_s
    content_type
  end

  def inline_titleize
    content_type
  end

end


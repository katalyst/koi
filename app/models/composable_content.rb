class ComposableContent < ActiveRecord::Base

  has_crud orderable: true

  validates :content_type, presence: true

  belongs_to :composable, polymorphic: true

  dragonfly_accessor :file

  scope :active, -> { where(active: true) }

  ContentTypes = [
    "Heading",
    "Text",
    "Quote",
    "WYSIWYG",
    "File",
    "Gallery"
  ]

  delegate :type, to: :content_type

  crud.config do
    fields active:          { type: :boolean },
           content_type:    { type: :select, data: ContentTypes },
           # file_id:         { type: :uploader, types: "pdf, xls, xlsx, doc, docx", max_size: 10 },
           file:            { type: :file, wrapper_data: { show: "content_type", show_option: "File_&_Image", show_type: "any", show_inline: "true" } },
           string:          { wrapper_data: { show: "content_type", show_option: "Heading_&_Quote", show_type: "any", show_inline: "true" } },
           text:            { wrapper_data: { show: "content_type", show_option: "Text", show_type: "any", show_inline: "true" } },
           rich_text:       { type: :rich_text, wrapper_data: { show: "content_type", show_option: "WYSIWYG", show_type: "any", show_inline: "true" } }
    config :admin do
      form  fields: [:content_type, :string,  :text, :rich_text, :file]
    end
  end

  def data
    if content_type.eql?("Heading") || 
       content_type.eql?("Quote") 
      string
    elsif content_type.eql?("Text") 
      text
    elsif content_type.eql?("WYSIWYG") 
      rich_text
    elsif content_type.eql?("File") ||
          content_type.eql?("Image") 
      file
    end
  end

  def to_s
    content_type
  end

  def inline_titleize
    content_type
  end

end


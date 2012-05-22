module Koi::IconHelper

  # Creates a thumbnail version of the image.
  #
  # Example:
  #
  #     image_thumbnail(file, width: 200, height: 200) # => /media/gtoZWlnaHRpaQ/example.png
  #
  def image_thumbnail(image, options={})
    image.process(:resize_and_crop, options).url
  end

  # Gets the icon for a document. This uses the Koi::Asset::Document.icons config.
  #
  # Example:
  #
  #     document_icon(file) # => /assets/koi/application/icon-file-pdf.png
  #
  def document_icon(document)
    ext = File.extname(document.name).gsub('.', '')
    Koi::Asset::Document.icons.has_key?(ext) ? Koi::Asset::Document.icons[ext] : Koi::Asset.unknown_image
  end

  # Returns an images that represents the given attachment. If it's a images it'll be a cropped
  # version. If the given attachment is a document the image iamge returned will be an icon.
  #
  # Example:
  #
  #     attachment_image_tag(file, width: 50, height: 50) # => <img src="/page/to/image.png" width="50" height="50" />
  #
  def attachment_image_tag(attachment, options={})
    options.reverse_merge!(width: 100, height: 100)
    image_tag((attachment.image? ? image_thumbnail(attachment, options) : document_icon(attachment)), options)
  end

  # Return a unique ID.
  def identifier
    SecureRandom.hex(16)
  end

end

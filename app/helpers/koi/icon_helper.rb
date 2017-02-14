module Koi::IconHelper

  # Creates a thumbnail version of the image.
  #
  # Example:
  #
  #     image_thumbnail(file, width: 200, height: 200) # => /media/gtoZWlnaHRpaQ/example.png
  #
  def image_thumbnail(image, options={})
    image.thumb("#{options[:width]}x#{options[:height]}").url
  end

  # Gets the icon for a document. This uses the Koi::KoiAsset::Document.icons config.
  #
  # Example:
  #
  #     document_icon(file) # => /assets/koi/application/icon-file-pdf.png
  #
  def document_icon(document)
    if document.name
      ext = File.extname(document.name).gsub('.', '')
    else
      # prevents broken file uploads from crashing on subsequent page edits
      ext = "none"
    end
    Koi::KoiAsset::Document.icons.has_key?(ext) ? Koi::KoiAsset::Document.icons[ext] : Koi::KoiAsset.unknown_image
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
    is_image  = attachment.app.name == :image
    thumbnail = is_image ? image_thumbnail(attachment, options) : document_icon(attachment)
    image_tag(thumbnail, options)
  end

  # Return a unique ID.
  def identifier
    SecureRandom.hex(16)
  end

  private

    def document?(ext)
      /pdf|xlsx?|docx?|txt|rtf/i === ext || ! image?(ext)
    end

    def image?(ext)
      /png|jp?g|gif/i === ext
    end

end

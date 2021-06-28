module Koi::IconHelper

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
    Koi::KoiAsset::Document.icons.has_key?(ext) ? path_to_asset(Koi::KoiAsset::Document.icons[ext]) : path_to_asset(Koi::KoiAsset.unknown_image)
  end

  # Returns an images that represents the given attachment. If it's an image it'll be a cropped
  # version. If the given attachment is a document the image returned will be an icon.
  #
  # Example:
  #
  #     attachment_image_tag(file, width: 50, height: 50) # => <img src="/page/to/image.png" width="50" height="50" />
  #
  def attachment_image_tag(attachment, options={})
    options.reverse_merge!(width: 100, height: 100)
    is_image  = attachment.app.name == :image
    thumbnail = is_image ? image_thumbnail(attachment, options) : document_thumbnail(attachment)
    image_tag(thumbnail, options)
  rescue StandardError
    "Image not found"
  end

  # Return a unique ID.
  def identifier
    SecureRandom.hex(16)
  end

  private

  def document?(ext)
    /pdf|xlsx?|docx?|txt|rtf/i === ext || !image?(ext)
  end

  def image?(ext)
    /png|jp?g|gif/i === ext
  end
end

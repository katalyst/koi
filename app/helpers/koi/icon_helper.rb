module Koi::IconHelper

  # def is_image?(file)
  #   ext = File.extname(file).gsub('.', '')
  #   KOI_ASSET_DOCUMENT_ICONS.has_key?(ext) ? false : true
  # end
  #
  # def icon_url(file)
  #   ext = File.extname(file).gsub('.', '')
  #   KOI_ASSET_DOCUMENT_ICONS.has_key?(ext) ? KOI_ASSET_DOCUMENT_ICONS[ext] : KOI_ASSET_UNKNOWN_IMAGE
  # end
  #
  # def thumb(file, *args)
  #   send "thumb_#{file.image? ? :image : :icon}", file, *args
  # end
  #
  # def thumb_image(file, opt = {})
  #   opt = thumb_html({ width:100, height:100 }.merge(opt))
  #   image_tag file.thumb(thumb_dragonfly opt).url, opt
  # end
  #
  # def thumb_icon(file, opt = {})
  #   opt = thumb_html({ width:30, height:30 }.merge(opt))
  #   image_tag icon_url(file), opt
  # end
  #
  # def thumb_dragonfly(opt)
  #   "#{opt[:width]}x#{opt[:height]}#"
  # end
  #
  # def thumb_style(opt)
  #   "width:#{opt[:width]}px;height:#{opt[:height]}px;"
  # end
  #
  # def thumb_html(opt)
  #   opt.merge(style: thumb_style(opt))
  # end

  # Creates a thumbnail version of the image.
  #
  # Example:
  #
  #     image_thumbnail(file, width: 200, height: 200) # => /media/gtoZWlnaHRpaQ/example.png
  #
  def image_thumbnail(image, options={})
    image.process(:resize_and_crop, options).url
  end

  # Gets the icon for a document. This uses the KOI_ASSET_DOCUMENT_ICONS config.
  #
  # Example:
  #
  #     document_icon(file) # => /assets/koi/icon/file/pdf.png
  #
  def document_icon(document)
    ext = File.extname(document.name).gsub('.', '')
    KOI_ASSET_DOCUMENT_ICONS.has_key?(ext) ? KOI_ASSET_DOCUMENT_ICONS[ext] : KOI_ASSET_UNKNOWN_IMAGE
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
    image_tag (attachment.image? ? image_thumbnail(attachment, options) : document_icon(attachment)), options
  end

  # Return a unique ID.
  def identifier
    SecureRandom.hex(16)
  end

end

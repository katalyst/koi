module Koi::ImageHelper

  # Creates a thumbnail version of the image.
  # @param image [Image,Object] Image record or an object responding to 'thumb'
  #
  # Example:
  #
  #     image_thumbnail(file, width: 200, height: 200) # => /media/gtoZWlnaHRpaQ/example.png
  #
  def image_thumbnail(image, options={})
    options = { size: options } if options.is_a?(String)

    if image.respond_to?(:ext) && image.ext && image.ext.downcase.eql?("svg")
      raw image.url
    elsif Koi::KoiAsset.use_active_storage? && image.respond_to?(:attachment) && image.attachment.present?
      Rails.application.routes.url_helpers.url_for(image.attachment.variant(image_variant_size_options(options)))
    elsif defined?(Dragonfly)
      image = image.data if image.is_a?(Image)
      if options[:size]
        image.thumb(options[:size]).url
      elsif options[:width] || options[:height]
        image.thumb("#{options[:width]}x#{options[:height]}").url
      else
        image_url(image)
      end
    end
  end

  private

  def image_variant_size_options(options = {})
    opts = options.slice(:width, :height, :resize_to_fill, :resize_to_fit, :resize_to_limit, :resize_and_pad)

    size = options[:size] || options[:resize]
    if size.present? && (match = size.match(/(\d+)x(\d+)?(.*)?/))
      width, height, resize_options = match.captures
      if resize_options == ">"
        opts[:resize_to_fill] = [width.to_i, nil]
      else
        opts[:resize_to_fit] = [width.to_i, height.to_i]
      end
    end

    opts
  end

end

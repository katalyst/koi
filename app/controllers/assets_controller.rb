class AssetsController < Koi::CrudController

  def index
    redirect_to '/'
  end

  def show
    return super if params[:format].blank?
    return super if /(x|ht)ml?|js/i === params[:format]

    redirect_to url_for_asset
  end

  private

  def url_for_asset
    if resource.attachment.present?
      # active storage
      url_for_attachment(resource.attachment)
    elsif resource.data.present?
      # dragonfly
      url_for_asset_data(resource.data)
    end
  end

  def url_for_attachment(attachment)
    options = asset_options
    if attachment.variable? && (options[:width] || options[:height])
      variant_options = { resize_to_fit: [options[:width], options[:height]] }
      attachment = attachment.variant(variant_options)
    end
    url_for(attachment)
  end

  def url_for_asset_data(data)
    return data.url unless data.app.name.try(:to_sym).try(:eql?, :image)

    options = asset_options
    data    = data.thumb(options[:thumb]) if options[:thumb]
    data    = data.encode(options[:format])
    data.url
  end

  def asset_options
    width, height, format = params.values_at :width, :height, :format
    width                 = width.match(/[0-9]+/).to_s if width.present?
    height                = height.match(/[0-9]+/).to_s if height.present?
    thumb                 = "#{width}x#{height}" if width.present? || height.present?
    {
      width:  width,
      height: height,
      format: format,
      thumb:  thumb,
    }
  end
end

module Koi::NavigationHelper
  def cascaded_setting(key)
    active_item_prefixes = render_navigation renderer: :active_items
    active_item_prefixes << settings_prefix
    active_item_prefixes.uniq.compact!

    setting = nil

    if is_settable?
      active_item_prefixes.reverse.each do |prefix|
        break unless setting.blank?
        value = Setting.find_by_prefix_and_key(prefix, key).try(:value)
        setting = value unless value.blank?
      end
    end

    setting
  end

  def cascaded_banners
    images = cascaded_setting(:banners)
    image_tags = ""
    images.try(:each) do |image|
      image_tags << image_tag(image.url(size: "100x"))
    end
    image_tags
  end
end

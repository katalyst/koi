module Koi::NavigationHelper

  def is_mobile_agent?
    agent = request.user_agent
    full = /android|avantgo|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od|ad)|iris|kindle|lge |maemo|midp|mmp|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i
    part = /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|e\-|e\/|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(di|rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|xda(\-|2|g)|yas\-|your|zeto|zte\-/i
    return full === agent || part === agent[0,4]
  end

  def cascaded_setting key
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
    images = [] unless Enumerable === images
    images.sum { |image| image_tag image.url(size: "100x") }
  end

  # breadcrumbs is the trail from the root node leading up to the highlighted breadcrumb
  # 
  def breadcrumbs
    @breadcrumbs ||= breadcrumb.ancestors_and_self
  end

  # breadcrumb is the most highlighted NavItem in the sitemap, which is determined heuristally
  # using a combination of the stored highlights_on proc, a complete or partial path match etc
  # 
  def breadcrumb
    @breadcrumb ||= nav.self_and_descendants.compact.sort_by(&:negative_highlight).first
    # sorting by negative highlight ensures that root will be selected
    # if no nodes are highlighted
  end

  # nav returns the Navigator corresponding to the given argument (resolved by NavItem.for), e.g.:
  # - nil returns the root Navigator
  # - String returns the Navigator with that key
  # - NavItem returns the Navigator for itself
  # 
  def nav arg = nil
    navs_by_id[ NavItem.for(arg).id ]
  end

  # navs_by_id returns a hash mapping NavItem ids to Navigator instances
  # 
  def navs_by_id
    @navs_by_id ||= begin
      
      nav_items = NavItem.order :lft
      
      navs = nav_items.map do |nav_item|
        hash = nav_item.to_hashish binding()
        hash[:settings] ||= {}
        hash[:settings].merge! controller.settings_hash if controller.respond_to? :settings_hash
        Navigator.new self, hash
      end
      
      navs_by_id = navs.each_with_object({}) { |nav, obj| obj[nav.id] = nav }

      navs_by_id.each do |id, nav|
        if nav.parent_id
          nav.parent = navs_by_id[nav.parent_id]
          nav.parent.children << nav
        end
      end

      navs_by_id
    end
  end

end

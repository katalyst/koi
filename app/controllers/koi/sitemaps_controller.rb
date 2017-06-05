module Koi
  class SitemapsController < ApplicationController

    def show
      slug = params[:id]
      koi_navitem = Koi::Sitemap.root_items.select { |navitem| navitem["key"].eql?(slug) }.first
      @nav_item = NavItem.find_by_key(slug)
      if !@nav_item.present? 
        if koi_navitem.present?
          flash.now[:notice] = "Generating new sitemap"
          @nav_item = RootNavItem.create!(koi_navitem)
        else
          flash.now[:error] = "Unknown Sitemap"
        end
      end
    end

  end
end

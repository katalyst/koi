# frozen_string_literal: true

module Koi
  class LegacyPagesController < AdminCrudController
    defaults route_prefix: ""

    def destroy
      super do |format|
        format.html { redirect_to sitemap_nav_items_path }
      end
    end
  end
end

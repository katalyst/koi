module Koi
  class PagesController < AdminCrudController

    has_scope :type, default: 'Page', only: [:index] do |controller, scope, value|
      scope.where('type = ? or type is null', value)
    end

    defaults :route_prefix => ''

    def destroy
      super do |format|
        format.html { redirect_to sitemap_nav_items_path }
      end
    end

  end
end

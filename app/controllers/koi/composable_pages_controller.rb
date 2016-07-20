module Koi
  class ComposablePagesController < AdminCrudController

    defaults :route_prefix => ''
    defaults :resource_class => ComposablePage

    def destroy
      super do |format|
        format.html { redirect_to sitemap_nav_items_path }
      end
    end

  end
end

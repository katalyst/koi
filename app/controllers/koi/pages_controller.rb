module Koi
  class PagesController < AdminCrudController

    defaults :route_prefix => ''

    def destroy
      super do |format|
        format.html { redirect_to sitemap_nav_items_path }
      end
    end

    def orphans
      @pages = get_orphan_pages.page(params[:page]).per(20)
    end

    def restore_orphan
      @page = Page.find(params[:id])
      @page.to_navigator!({ parent_id: NavItem.root.id })
      redirect_to sitemap_nav_items_path
    end

  end
end

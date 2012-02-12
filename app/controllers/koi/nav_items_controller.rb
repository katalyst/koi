module Koi
  class NavItemsController < AdminCrudController
    custom_actions resource: :toggle

    def new
      @site_parent = NavItem.find(params[:site_parent])
      super
    end

    def create
      create! do |success, failure|
        success.html { redirect_to redirect_path }
        success.js
        failure.js
      end
    end

    def update
      update! do |success, failure|
        success.html { redirect_to redirect_path }
        success.js
        failure.js
      end
    end

    def destroy
      destroy! do |format|
        format.html { redirect_to redirect_path }
        format.js
      end
    end

    def sitemap
       @nav_items = NavItem.all
    end

    def savesort
      neworder = JSON.parse(params[:set])
      prev_item = nil
      neworder.each do |item|
        dbitem = NavItem.find(item['id'])
        prev_item.nil? ? dbitem.move_to_root : dbitem.move_to_right_of(prev_item)
        sort_children(item, dbitem) unless item['children'].nil?
        prev_item = dbitem
      end
      NavItem.rebuild!
      render partial: "nav_item_root", locals: { nav_item: RootNavItem.root }
    end

    def sort_children(element,dbitem)
      prevchild = nil
      element['children'].each do |child|
        childitem = NavItem.find(child['id'])
        prevchild.nil? ? childitem.move_to_child_of(dbitem) : childitem.move_to_right_of(prevchild)
        sort_children(child, childitem) unless child['children'].nil?
        prevchild = childitem
      end
    end

    def toggle
      resource.toggle_hidden!
      respond_to do |format|
        format.html { redirect_path }
        format.js
      end
    end

  protected

    def redirect_path
      if params[:commit].eql?("Continue")
        edit_resource_url
      else
        sitemap_nav_items_path
      end
    end
  end
end

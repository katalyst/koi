module Koi
  class NavItemsController < AdminCrudController
    defaults :route_prefix => ''
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
      nodes = JSON.parse params[:set]                                  # get list of nodes
      nodes.map! &:symbolize_keys                                      # symbolize keys for % format
      nodes.map! { |node| node.merge!(node) { |key, val| val.to_i } }  # sanitize everything as int
      nodes.each { |node| node[:parent_id] ||= "NULL" }                # default parent for root
      
      ids = nodes.map { |node| node[:id] }

      # mass update (should be abstracted)
      # better than for loop as we get a free transaction i think?
      NavItem.connection.execute <<-eos
        UPDATE nav_items
          SET lft = CASE id
                      #{ nodes.map { |node| "WHEN %{id} THEN %{lft}" % node }.join "\n" }
                    END,
              rgt = CASE id
                      #{ nodes.map { |node| "WHEN %{id} THEN %{rgt}" % node }.join "\n" }
                    END,
              parent_id = CASE id
                      #{ nodes.map { |node| "WHEN %{id} THEN %{parent_id}" % node }.join "\n" }
                    END                    
        WHERE id in (#{ ids.join ',' })
      eos
      render partial: "nav_item", locals: { nav_item: RootNavItem.root, level: 0 }
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

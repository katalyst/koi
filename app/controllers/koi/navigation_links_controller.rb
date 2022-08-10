# frozen_string_literal: true

module Koi
  class NavigationLinksController < Koi::ApplicationController
    before_action :set_menu
    before_action :set_link, except: %i[index new create]

    def index
      render locals: { links: @menu.navigation_links }
    end

    def new
      render locals: { link: @menu.navigation_links.build }
    end

    def create
      link = @menu.navigation_links.build(navigation_link_params)
      if link.save
        render :update, locals: { link: link, previous: NavigationLink.new }, notice: "Navigation link created"
      else
        render :new, status: :unprocessable_entity, locals: { link: link }
      end
    end

    def show; end

    def edit
      render locals: { link: @link }
    end

    # PATCH /admins/navigation_menu/:slug/navigation_link/:id
    def update
      @link.attributes = navigation_link_params

      if @link.valid?
        previous = @link
        @link    = @link.dup.tap(&:save!)
        render locals: { link: @link, previous: previous }, notice: "Navigation link updated"
      else
        render :edit, status: :unprocessable_entity, locals: { link: @link }
      end
    end

    private

    def navigation_link_params
      params.require(:navigation_link).permit(%i[title url visible new_tab])
    end

    def set_menu
      @menu = NavigationMenu.find_by!(slug: params[:navigation_menu_id])
    end

    def set_link
      @link = NavigationLink.find(params[:id])
    end
  end
end

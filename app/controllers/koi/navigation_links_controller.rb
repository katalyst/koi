# frozen_string_literal: true

module Koi
  class NavigationLinksController < Koi::ApplicationController
    before_action :set_menu
    before_action :set_link, except: %i[index new create]

    def index
      render locals: { links: @menu.items }
    end

    def new
      render locals: { link: @menu.items.build }
    end

    def create
      link = @menu.items.build(link_params)
      if link.save
        render :update, locals: { link: link, previous: Katalyst::Navigation::Link.new }
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
      @link.attributes = link_params

      if @link.valid?
        previous = @link
        @link    = @link.dup.tap(&:save!)
        render locals: { link: @link, previous: previous }
      else
        render :edit, status: :unprocessable_entity, locals: { link: @link }
      end
    end

    private

    def link_params
      params.require(:link).permit(%i[title url visible new_tab])
    end

    def set_menu
      @menu = Katalyst::Navigation::Menu.find_by!(slug: params[:navigation_menu_id])
    end

    def set_link
      @link = Katalyst::Navigation::Link.find(params[:id])
    end
  end
end

class Koi::NavigationMenusController < Koi::ApplicationController
  include Katalyst::Tables::Backend

  def index
    sort, menus = table_sort(NavigationMenu.all)

    render locals: { menus: menus, sort: sort }
  end

  def new
    render locals: { menu: NavigationMenu.new }
  end

  def create
    @menu = NavigationMenu.new(navigation_menu_params)

    if @menu.save
      redirect_to @menu, notice: "Navigation menu created"
    else
      render :new, locals: { menu: @menu }, status: :unprocessable_entity
    end
  end

  def show
    menu = NavigationMenu.find_by!(slug: params[:id])

    render locals: { menu: menu }
  end

  # PATCH /admins/navigation_menus/:slug
  def update
    menu = NavigationMenu.find_by!(slug: params[:id])

    menu.attributes = navigation_params

    unless menu.valid?
      return render :show, locals: { menu: menu }, status: :unprocessable_entity
    end

    case params[:commit]
    when "publish"
      menu.save!
      menu.publish!
    when "save"
      menu.save!
    when "revert"
      menu.revert!
    end
    redirect_to menu
  end

  def destroy
    menu = NavigationMenu.find_by!(slug: params[:id])

    menu.destroy!

    redirect_to navigation_menus_path, notice: "Navigation menu destroyed"
  end

  private

  def navigation_menu_params
    params.require(:navigation_menu).permit(:title, :slug)
  end

  def navigation_params
    return {} if params[:navigation_menu].blank?

    params.require(:navigation_menu)
          .permit(navigation_links_attributes: [:id, :index, :depth])
  end
end

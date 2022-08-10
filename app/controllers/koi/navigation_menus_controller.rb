class Koi::NavigationMenusController < Koi::ApplicationController
  include Katalyst::Tables::Backend

  def index
    sort, menus = table_sort(Katalyst::Navigation::Menu.all)

    render locals: { menus: menus, sort: sort }
  end

  def new
    render locals: { menu: Katalyst::Navigation::Menu.new }
  end

  def create
    @menu = Katalyst::Navigation::Menu.new(menu_params)

    if @menu.save
      redirect_to navigation_menu_path(@menu), notice: "Navigation menu created"
    else
      render :new, locals: { menu: @menu }, status: :unprocessable_entity
    end
  end

  def show
    menu = Katalyst::Navigation::Menu.find_by!(slug: params[:id])

    render locals: { menu: menu }
  end

  # PATCH /admins/navigation_menus/:slug
  def update
    menu = Katalyst::Navigation::Menu.find_by!(slug: params[:id])

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
    redirect_to navigation_menu_path(menu)
  end

  def destroy
    menu = Katalyst::Navigation::Menu.find_by!(slug: params[:id])

    menu.destroy!

    redirect_to navigation_menus_path, notice: "Navigation menu destroyed"
  end

  private

  def menu_params
    params.require(:menu).permit(:title, :slug)
  end

  def navigation_params
    return {} if params[:menu].blank?

    params.require(:menu)
          .permit(items_attributes: [:id, :index, :depth])
  end
end

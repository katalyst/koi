class Admin::KoiCrudController < Admin::BaseController
  has_crud :admin => true

  def show
    redirect_to edit_resource_path
  end

end


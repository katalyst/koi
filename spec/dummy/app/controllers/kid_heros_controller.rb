class KidHerosController < Koi::CrudController

  protected

    def permitted_params
      params.permit(kid_hero: [:name, :gender])
    end

end

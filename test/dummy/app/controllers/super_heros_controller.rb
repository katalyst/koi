class SuperHerosController < Koi::CrudController

  protected

    def permitted_params
      params.permit(super_hero: [:name, :description, :published_at, :gender,
                                 :is_alive, :url, :telephone])
    end

end

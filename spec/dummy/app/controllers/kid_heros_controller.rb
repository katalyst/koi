# frozen_string_literal: true

class KidHerosController < Koi::CrudController
  protected

  def permitted_params
    params.permit(kid_hero: %i[name gender])
  end
end

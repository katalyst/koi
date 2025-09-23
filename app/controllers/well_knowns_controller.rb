# frozen_string_literal: true

class WellKnownsController < ActionController::API
  def show
    well_known = WellKnown.find_by(name: params[:name])

    case well_known&.format
    when :text
      render plain: well_known.content
    when :json
      render json: well_known.content
    else
      head :not_found
    end
  end
end

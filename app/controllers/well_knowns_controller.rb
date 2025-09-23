# frozen_string_literal: true

class WellKnownsController < ActionController::Base
  before_action :set_well_known

  attr_reader :well_known

  def show
    if well_known.present?
      render renderable: @well_known
    else
      head :not_found
    end
  end

  private

  def set_well_known
    @well_known = WellKnown.find_by(name: params[:name])
  end
end

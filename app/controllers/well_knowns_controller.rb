# frozen_string_literal: true

class WellKnownsController < ApplicationController
  before_action :set_well_known

  def show
    render renderable: @well_known
  end

  private

  def set_well_known
    @well_known = WellKnown.find_by!(name: params[:name])
  end
end

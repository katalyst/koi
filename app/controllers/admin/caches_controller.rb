# frozen_string_literal: true

module Admin
  class CachesController < ApplicationController
    def destroy
      Rails.logger.warn("[CACHE CLEAR] - Cleaning entire cache manually by #{current_admin} request")
      Rails.cache.clear
      redirect_back(fallback_location: admin_dashboard_path)
    end
  end
end

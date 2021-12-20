# frozen_string_literal: true

module Koi
  class DocumentsController < Koi::AssetsController
    defaults route_prefix: "", resource_class: Document

    def create
      create! do |success, failure|
        failure.html do
          logger.warn("[Asset Upload] - #{resource.errors.messages[:data].join(', ')}")
          render json: resource.errors, status: :unprocessable_entity
        end
        failure.js do
          logger.warn("[Asset Upload] - #{resource.errors.messages[:data].join(', ')}")
          render json: resource.errors, status: :unprocessable_entity
        end
        success.js { render plain: resource.id }
      end
    end
  end
end

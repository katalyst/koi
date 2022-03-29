# frozen_string_literal: true

class AssetsController < Koi::CrudController
  def show
    return super if params[:format].blank?
    return super if /(x|ht)ml?|js/i.match?(params[:format])

    redirect_to data_path resource.data
  end

  def data_path(data)
    return data.url unless data.app.name.try(:to_sym).try(:eql?, :image)

    width, height, format = params.values_at :width, :height, :format
    width = width.match(/[0-9]+/).to_s if width.present?
    height = height.match(/[0-9]+/).to_s if height.present?
    data = data.thumb "#{width}x#{height}" unless width.blank? && height.blank?
    data = data.encode format
    data.url
  end

  # Stop accidental leakage of unwanted actions to frontend

  def index
    redirect_to "/"
  end

  alias create index
  alias destroy index
  alias update index
  alias edit index
  alias new index
end

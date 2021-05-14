module Koi
  class UploadsController < AdminCrudController

    skip_before_action :verify_authenticity_token, only: [:create, :image]

    def create
      image = Image.new
      image.data = params[:file]
      image.save
      render plain: image.url
    end

    def file
      file = Document.new
      file.data = params[:file]
      file.save
      render plain: file.id
    end

    def image
      image = Image.new
      image.data = params[:file]
      image.save
      render plain: image.id
    end

  end
end

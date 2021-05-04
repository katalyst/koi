module Koi
  class UploadsController < AdminCrudController

    skip_before_action :verify_authenticity_token, only: [:create, :image]

    def create
      image = Image.new
      image.data = params[:file]
      image.save
      render text: image.url
    end

    def file
      file = Document.new
      file.data = params[:file]
      file.save
      render text: file.id
    end

    def image
      image = Image.new
      image.data = params[:file]
      image.save
      render text: image.id
    end

  end
end

# frozen_string_literal: true

module Koi
  class UploadsController < AdminCrudController
    skip_before_action :verify_authenticity_token # TODO[asw]: send CSRF token for uploads

    # params[:upload] is present if the "Send it to the server" button was pressed.
    # params[:file] is present if the data was uploaded by kat-image-upload.js
    def create
      asset      = asset_class.new
      asset.data = params[:upload] || params[:file]
      asset.save

      if params[:upload]
        response = {
          uploaded: 1,
          fileName: asset.data_name,
          url:      asset.url,
        }
        render json: response
      else
        render plain: url_for(asset)
      end
    end

    private

    def asset_class
      case params[:asset_type].to_s
      when "Image"
        Image
      when "Document"
        Document
      else
        raise "unsupported asset type"
      end
    end
  end
end

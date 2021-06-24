module Koi
  class UploadsController < AdminCrudController
    skip_before_action :verify_authenticity_token # TODO[asw]: send CSRF token for uploads

    def create
      asset = asset_class.new
      asset.data = params[:file]
      asset.save
      render plain: asset.id
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

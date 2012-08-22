class AssetsController < Koi::CrudController

  def show
    respond_to do |format|
      format.html { super }
      format.all { redirect_to data_path resource.data }
    end
  end

  def data_path data
    return data.url unless data.image?
    data = data.thumb "#{ params[:width] }x#{ params[:height] }" unless params[:width].blank? && params[:height].blank?
    data = data.encode params[:format]
    data.url
  end

end

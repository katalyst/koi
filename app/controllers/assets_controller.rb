class AssetsController < Koi::CrudController

  def show
    respond_to do |format|
      format.html { super }
      format.all { redirect_to data_path resource.data }
    end
  end

  def data_path data
    return data.url unless data.image?
    width, height, format = params.values_at :width, :height, :format
    width  =  width.match(/[0-9]+/).to_s if width.present?
    height = height.match(/[0-9]+/).to_s if height.present?
    data = data.thumb "#{ width }x#{ height }" unless width.blank? && height.blank?
    data = data.encode format
    data.url
  end

end

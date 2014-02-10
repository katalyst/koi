class AssetsController < Koi::CrudController

  def show
    return super if params[:format].blank?
    return super if /(x|ht)ml?|js/i === params[:format]
    return redirect_to data_path resource.data
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

  # Stop accidental leakage of unwanted actions to frontend

  def index
    redirect_to '/'
  end

  alias :index :create
  alias :index :destroy
  alias :index :update
  alias :index :edit
  alias :index :new

end

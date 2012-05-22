module Koi
  class AssetsController < AdminCrudController
    before_filter :init

    def new
      params[:asset] = { :tag_list => [ @tags ] }
      super
    end

    def show
    end

    def create
      create! do |success, failure|
        success.html { redirect_to edit_resource_path }
        success.js
      end
    end

    def update
      super do |success, failure|
        success.html {  }
        success.js
        redirect_to edit_resource_path
      end
    end

    def delete
      respond_to do |format|
        format.html # delete.html.erb
      end
    end

    # HELPERS ########################################################################################

    def url_options
      super.reverse_merge(custom_url_options)
    end

    def custom_url_options
      @custom_url_options || {}
    end

    def custom_url_options=(options)
      @custom_url_options = (@custom_url_options || {}).merge(options) if options.is_a?(Hash)
    end

    protected

    def sort_column
      resource_class.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

    def collection
      return get_collection_ivar unless get_collection_ivar.nil?
      coll = end_of_association_chain
      coll = coll.unassociated
      coll = coll.search_for params[:search]
      coll = coll.tagged_with @tags unless @tags.blank?
      coll = coll.order sort_column + " " + sort_direction
      set_collection_ivar coll
    end

    def init
      @tags = params[:tags] || []
      @all_tags = resource_class.tag_counts_on(:tags).collect { |x| x.name }
      self.custom_url_options = { :tags => @tags, :CKEditorFuncNum => params[:CKEditorFuncNum] }
    end

    def create_resource(object)
      object.data = params[:file].tempfile
      object.data_name = params[:file].original_filename
      object.tag_list = params[:tag_list]
      object.save
    end
  end
end
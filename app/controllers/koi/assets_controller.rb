# frozen_string_literal: true

module Koi
  class AssetsController < AdminCrudController
    before_action :init

    layout "koi/assets"

    def index
      @assets = collection.newest_first.page(params[:page]).per(20)
      params[:asset] = { tag_list: [@tags] }
      super
    end

    def new
      @assets = collection.newest_first.page(params[:page]).per(20)
      params[:asset] = { tag_list: [@tags] }
      super
    end

    def show
      @assets = collection.newest_first.page(params[:page]).per(20)
    end

    def edit
      @assets = collection.newest_first.page(params[:page]).per(20)
    end

    def create
      super do |format|
        format.html { redirect_to resource_path(resource) }
        format.js { render plain: resource.id }
      end
    end

    def destroy
      super do |format|
        format.html { redirect_to new_resource_path }
        format.js
      end
    end

    # HELPERS ########################################################################################

    def redirect_path
      resource_path(resource)
    end

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
      coll = coll.search_data params[:search]
      coll = coll.tagged_with @tags if @tags.present?
      coll = coll.order "#{sort_column} #{sort_direction}"
      set_collection_ivar coll
    end

    def init
      @tags = params[:tags] || []
      @all_tags = resource_class.tag_counts_on(:tags).map(&:name)
      self.custom_url_options = { tags: @tags }
    end

    def create_resource(object)
      object.data = params[:file]
      object.data_name = params[:file].original_filename
      object.tag_list = params[:tag_list]
      object.save
    end
  end
end

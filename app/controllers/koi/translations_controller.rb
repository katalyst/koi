module Koi
  class TranslationsController < AdminCrudController
    defaults :route_prefix => ''

    def seed
      Translation.create(label: "Site Title", key: "site.title", value: "", field_type: "string", role: "Admin")
      Translation.create(label: "Site Meta Description", key: "site.meta_description", value: "", field_type: "text", role: "Admin")
      Translation.create(label: "Site Meta Keywords", key: "site.meta_keywords", value: "", field_type: "text", role: "Admin")
      Translation.create(label: "Google Analytics Profile ID", key: "site.google_analytics.profile_id", value: "", field_type: "string", role: "Admin")
      Translation.create(label: "Twitter Search Query", key: "site.twitter.widget_id", value: "", field_type: "string", role: "Admin")
      redirect_to collection_path, notice: "Google Analytics and Twitter settings created."
    end

    protected

    def collection
      @translations ||= (current_admin.god? ?
        end_of_association_chain.non_prefixed : end_of_association_chain.non_prefixed.admin)
    end

    def is_settable?
      false
    end
  end
end

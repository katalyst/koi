module Koi
  class TranslationsController < AdminCrudController
    defaults :route_prefix => ''

    def seed
      Translation.create(label: "Site Title", key: "site.title", value: "Site Title", field_type: "string", role: "Admin")
      Translation.create(label: "Site Meta Description", key: "site.meta_description", value: "Meta Description", field_type: "text", role: "Admin")
      Translation.create(label: "Site Meta Keywords", key: "site.meta_keywords", value: "Meta Keywords", field_type: "text", role: "Admin")
      Translation.create(label: "Google Analytics", key: "site.google_analytics_embed", value: "<script></script>", field_type: "text", role: "Admin")
      Translation.create(label: "Google Analytics Username", key: "site.google_analytics.username", value: "admin@katalyst.com.au", field_type: "string", role: "Admin")
      Translation.create(label: "Google Analytics Password", key: "site.google_analytics.password", value: "yAw7c9rV", field_type: "string", role: "Admin")
      Translation.create(label: "Google Analytics Profile ID", key: "site.google_analytics.profile_id", value: "UA-2161859-1", field_type: "string", role: "Admin")
      Translation.create(label: "Twitter Search Query", key: "site.twitter.widget_id", value: "389900838295965696", field_type: "string", role: "Admin")
      Translation.create(label: "Show Google Analytics", key: "site.show.dashboard.analytics", value: "true", field_type: "boolean", role: "Super")
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

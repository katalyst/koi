module Koi
  class TranslationsController < AdminCrudController
    defaults :route_prefix => ''

    def seed
      Translation.create(label: "Google Analytics", key: "site.google_analytics", value: "<script></script>", field_type: "text", role: "Admin")
      Translation.create(label: "Google Analytics Username", key: "site.google_analytics.username", value: "admin@katalyst.com.au", field_type: "string", role: "Admin")
      Translation.create(label: "Google Analytics Password", key: "site.google_analytics.password", value: "yAw7c9rV", field_type: "string", role: "Admin")
      Translation.create(label: "Google Analytics Profile ID", key: "site.google_analytics.profile_id", value: "UA-2161859-1", field_type: "string", role: "Admin")
      Translation.create(label: "Twitter Search Query", key: "site.twitter.query", value: "from:twitter OR #twitter", field_type: "string", role: "Admin")
      Translation.create(label: "Show Google Analytics", key: "site.show.dashboard.analytics", value: "true", field_type: "boolean", role: "Super")
      redirect_to collection_path, notice: "Google Analytics and Twitter settings created."
    end

    protected

    def collection
      @translations ||= (current_admin.god? ?
        end_of_association_chain.all : end_of_association_chain.admin)
    end
  end
end

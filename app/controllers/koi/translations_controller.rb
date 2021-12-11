# frozen_string_literal: true

module Koi
  class TranslationsController < AdminCrudController
    defaults route_prefix: ""

    def seed
      Translation.create(prefix: "site", label: "Site Title", key: "site.title", value: "", field_type: "string",
                         role: "Admin")
      Translation.create(prefix: "site", label: "Site Meta Description", key: "site.meta_description", value: "",
                         field_type: "text", role: "Admin")
      Translation.create(prefix: "site", label: "Site Meta Keywords", key: "site.meta_keywords", value: "",
                         field_type: "text", role: "Admin")
      Translation.create(prefix: "site", label: "Google Analytics Profile ID", key: "site.google_analytics.profile_id",
                         value: "", field_type: "string", role: "Admin")
      Translation.create(prefix: "site", label: "Twitter Search Query", key: "site.twitter.widget_id", value: "",
                         field_type: "string", role: "Admin")
      redirect_to collection_path, notice: "Google Analytics and Twitter settings created."
    end

    protected

    def collection
      @translations ||= if current_admin.god?
                          end_of_association_chain.site_settings
                        else
                          end_of_association_chain.site_settings.admin
                        end
    end

    def is_settable?
      false
    end
  end
end

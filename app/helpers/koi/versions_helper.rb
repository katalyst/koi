module Koi
  module VersionsHelper
    def version_status_bar(resource, form_id:)
      tag.div class: "version-status-bar", data: { edit_target: "state", state: resource.state } do
        output_buffer << version_status_text(:published, last_update: l(resource.updated_at, format: :short))
        output_buffer << version_status_text(:draft)
        output_buffer << version_status_text(:dirty)
        output_buffer << tag.span(class: "version-actions") do
          output_buffer << version_action_button(:discard, form: form_id)
          output_buffer << version_action_button(:revert, form: form_id) if resource.state == :draft
          output_buffer << version_action_button(:save, form: form_id, class: "button button-outline")
          output_buffer << version_action_button(:publish, form: form_id, class: "button")
        end
      end
    end

    def version_status_text(state, **options)
      tag.span(t("views.koi.versions.status.#{state}_html", **options),
               class: "status-text",
               data:  { state => "" })
    end

    def version_action_button(action, **options)
      button_tag(t("views.koi.versions.action.#{action}", default: action.to_s.capitalize),
                 name:  "commit",
                 value: action,
                 **options)
    end
  end
end

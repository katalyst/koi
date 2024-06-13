# frozen_string_literal: true

ActiveSupport.on_load(:action_view) do
  # Workaround for de-duplicating nested module paths for admin controllers
  # https://github.com/rails/rails/issues/50916
  ActionView::AbstractRenderer::ObjectRendering.define_method(
    :merge_prefix_into_object_path,
    Koi::Extensions::ObjectRendering.instance_method(:merge_prefix_into_object_path),
  )
end

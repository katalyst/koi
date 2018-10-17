# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|

  config.wrappers :koi_debug, tag: :div do |b|
    b.wrapper tag: :div, class: :controls do |ba|
      ba.use :label
    end
  end

  config.wrappers :koi, tag: :div, class: 'control-group', error_class: :error, hint_class: :hint do |b|
    b.use :placeholder
    b.use :label
    b.use :hint,  wrap_with: { tag: :p, class: 'hint-block' }
    b.wrapper tag: :div, class: :controls do |ba|
      ba.use :input
    end
    b.use :error, wrap_with: { tag: :p, class: 'error-block' }
  end

  config.wrappers :koi_checkbox, tag: :div, class: 'control-group checkbox__single', error_class: :error, hint_class: :hint do |b|
    b.use :hint,  wrap_with: { tag: :p, class: 'hint-block' }
    b.wrapper tag: :div, class: :controls do |ba|
      ba.use :label_input
    end
    b.use :error, wrap_with: { tag: :p, class: 'error-block' }
  end

  config.default_wrapper = :koi_debug
  config.boolean_style = :nested
  config.error_notification_tag = :div
  config.error_notification_class = 'alert alert-error'
  config.label_class = 'control-label'
  config.browser_validations = false

end
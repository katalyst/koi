SimpleForm.setup do |config|

  # Default wrapper which DOES NOT render an input field
  # This is to highlight that the form field NEEDS to have it's wrapper defined as :koi
  config.wrappers :koi_debug, tag: :div do |b|
    b.wrapper tag: :div, class: "form__needs-wrapper" do |ba|
      ba.use :label
    end
  end

  # Generic input wrapper for all koi input fields
  config.wrappers :koi, tag: :div,
    class: 'control-group',
    error_class: :error,
    hint_class: :hint do |b|

    b.use :placeholder
    b.use :label, class: 'control-label'
    b.use :hint,  wrap_with: { tag: :p, class: 'hint-block' }
    b.wrapper tag: :div, class: :controls do |ba|
      ba.use :input
    end
    b.use :error, wrap_with: { tag: :p, class: 'error-block' }
  end

  # Specific checkbox wrapper to make boolean fields look nicer
  config.wrappers :koi_checkbox, tag: :div, 
    class: 'control-group checkbox__single',
    error_class: :error,
    hint_class: :hint,
    boolean_label_class: "checkbox control-label",
    boolean_style: :nested do |b|

    b.use :hint,  wrap_with: { tag: :p, class: 'hint-block' }
    b.wrapper tag: :div, class: :controls do |ba|
      ba.use :label_input
    end
    b.use :error, wrap_with: { tag: :p, class: 'error-block' }
  end

  # Baseline config updates that will get lost if custom simple_form initializer
  # is present
  config.default_wrapper = :koi_debug
  config.error_notification_tag = :div
  config.error_notification_class = 'panel panel__error'

end

SimpleForm::FormBuilder.map_type :jsonb, to: SimpleForm::Inputs::TextInput
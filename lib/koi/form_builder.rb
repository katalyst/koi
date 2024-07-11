# frozen_string_literal: true

module Koi
  class FormBuilder < ActionView::Helpers::FormBuilder
    include GOVUKDesignSystemFormBuilder::Builder
    include Koi::Form::Builder
  end
end

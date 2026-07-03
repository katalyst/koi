# frozen_string_literal: true

module Koi
  class FormBuilder < ActionView::Helpers::FormBuilder
    include GOVUKDesignSystemFormBuilder::Builder
    include Koi::Form::Builder

    delegate :content_tag, :tag, :safe_join, :link_to, :capture, to: :@template
  end
end

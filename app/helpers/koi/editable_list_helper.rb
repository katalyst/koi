module Koi::EditableListHelper
  extend ActiveSupport::Concern

  class EditableListBuilder
    def initialize(view_context)
      @view_context = view_context
    end

    def build(tag, html_options, &block)
      @view_context.content_tag(tag, options(html_options), &block)
    end

    def options(options)
      add_data(options, "controller", "editable-list")
      add_data(options, "action", <<~EVENTS)
        dragstart->editable-list#dragstart
        dragover->editable-list#dragover
        dragenter->editable-list#dragenter
        dragleave->editable-list#dragleave
        drop->editable-list#drop
        dragend->editable-list#dragend
      EVENTS

      options
    end

    private

    def add_data(options, key, value)
      options["data"][key] = [options["data"][key], value].compact.join(" ")
    end
  end

  def editable_list(tag_or_options = "ol", html_options = {}, &block)
    tag, html_options = if tag_or_options.is_a? Hash
                          ["ol", tag_or_options]
                        else
                          [tag_or_options, html_options]
                        end

    html_options         = html_options.deep_dup.stringify_keys
    html_options["data"] = html_options.fetch("data", {}).stringify_keys

    EditableListBuilder.new(self).build(tag, html_options, &block)
  end
end

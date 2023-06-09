# frozen_string_literal: true

class ResourceHeaderComponent < ViewComponent::Base
  attr_reader :model, :resource

  def initialize(resource: nil, model: resource&.class)
    super

    @model    = model
    @resource = resource
  end

  def render_in(view_context)
    @action_name = view_context.action_name

    super
  end

  def call
    render PageHeaderComponent.new(title:) do |header|
      case @action_name
      when "show"
        add_index(header)
        add_edit(header)
      when "new", "create"
        add_index(header)
      when "edit", "update"
        add_index(header)
        add_show(header)
      end
    end
  end

  def title(action = @action_name)
    case action
    when "show"
      resource_title
    when "new", "create"
      "New #{model_title.downcase}"
    when "edit", "update"
      "Edit #{model_title.downcase}"
    when "index"
      model_title.pluralize
    end
  end

  def model_title
    model.model_name.human
  end

  def resource_title
    if resource.respond_to?(:name)
      resource.name
    else
      resource.model_name.human
    end
  end

  def add_index(header)
    header.with_breadcrumb(title("index"), url_for(action: :index))
  end

  def add_show(header)
    header.with_breadcrumb(title("show"), url_for(action: :show, id: resource))
  end

  def add_edit(header)
    header.with_action("Edit", url_for(action: :edit, id: resource))
  end
end

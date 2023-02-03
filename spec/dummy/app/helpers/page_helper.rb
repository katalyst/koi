# frozen_string_literal: true

module PageHelper
  def page_banner(version:)
    render "/pages/banner", banner: Banner.new(self, version)
  end

  class Banner
    attr_reader :context, :version

    delegate :parent, to: :version
    delegate :state, to: :parent
    delegate_missing_to :context

    def initialize(context, version)
      @context   = context
      @version   = version
    end

    def date
      version.created_at.to_fs(:long)
    end

    def caption
      preview? ? state.capitalize : "Published"
    end

    def draft?
      state.in?(%i[draft unpublished])
    end

    def published?
      parent.published?
    end

    def preview?
      controller.action_name.eql? "preview"
    end

    def published_path
      polymorphic_path(parent) if published?
    end

    def draft_path
      "#{polymorphic_path(parent)}/preview"
    end

    def edit_path
      polymorphic_path([:admin, parent])
    end
  end
end

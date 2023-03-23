# frozen_string_literal: true

module Koi
  module Release
    def version
      @version ||= read(::Rails.root.join("VERSION"))
    end

    module_function :version

    def revision
      @revision ||= read(::Rails.root.join("REVISION"))
    end

    module_function :revision

    def meta_tags(context)
      ReleaseMetaTagsBuilder.new(context).render
    end

    module_function :meta_tags

    def read(file)
      return "HEAD" if Rails.env.development?
      return "unknown" unless File.exist?(file)

      File.read(file).strip
    end

    module_function :read
  end

  class ReleaseMetaTagsBuilder
    delegate_missing_to :@context

    def initialize(context)
      @context = context
    end

    def version
      tag.meta(name: "application-version", content: Koi::Release.version)
    end

    def revision
      tag.meta(name: "application-revision", content: Koi::Release.revision)
    end

    def render
      version + revision
    end
  end
end

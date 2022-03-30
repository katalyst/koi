# frozen_string_literal: true

module Koi
  class AdminCrudController < Koi::ApplicationController
    KOI_PATH_HELPER_RE = /(\w+_|\b)koi_(\w+)_path$/.freeze

    helper :all
    has_crud admin: true
    defaults route_prefix: "admin"

    def index
      respond_to do |format|
        format.html
        format.js
        format.csv { respond_with_csv }
      end
    end

    protected

    def respond_to_missing?(key, include_private = false)
      KOI_PATH_HELPER_RE.match?(key) || super
    end

    # Matches missing route methods of the form (action_)?koi_(controller)_path,
    # and sends them to koi_engine instead.
    #
    # This is necessary because inherited_resources is resolving paths differently
    # depending on whether they belong to the koi_engine or not.
    #
    def method_missing(key, *sig, &blk)
      if (match = KOI_PATH_HELPER_RE.match(key))
        prefix, suffix = match.to_a.drop 1
        koi_engine.send :"#{prefix}#{suffix}_path", *sig, &blk
      else
        super
      end
    end
  end
end

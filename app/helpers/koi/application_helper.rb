# frozen_string_literal: true

module Koi
  module ApplicationHelper
    include Katalyst::Tables::Frontend

    private

    # Icon Helper
    # <%= icon("close", width: 24, height: 24, stroke: "#BADA55", fill: "purple") %>
    def icon(icon_path, options = {})
      options[:width] = 24 if options[:width].blank?
      options[:height] = 24 if options[:height].blank?
      options[:stroke] = "#000000" if options[:stroke].blank?
      options[:fill] = "#000000" if options[:fill].blank?
      options[:class] = "" if options[:class].blank?
      render("koi/shared/icons/#{icon_path}", options: options)
    end
  end
end

# frozen_string_literal: true

require "rack/request"
require "rails_helper"

module Test
  HTML_ATTRIBUTES = {
    id:    "ID",
    class: "CLASS",
    html:  { style: "style" },
    data:  { foo: "bar" },
    aria:  { label: "LABEL" },
  }.freeze
end

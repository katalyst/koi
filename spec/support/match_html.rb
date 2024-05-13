# frozen_string_literal: true

require "compare-xml"
require "nokogiri"
require "rspec/matchers"

class HTMLMatcher < RSpec::Matchers::BuiltIn::BaseMatcher
  def initialize(expected_html, **options)
    super()

    # Options documented here: https://github.com/vkononov/compare-xml
    default_options = {
      collapse_whitespace: true,
      ignore_attr_order:   true,
      ignore_comments:     true,
    }

    @options = default_options.merge(options).merge(verbose: true)

    @actual        = nil
    @expected_html = expected_html
    @expected_doc  = Nokogiri::HTML.fragment(expected_html)
  end

  # @param [Object] response object to match against
  # @return [Boolean] `true` if response matches the expected html
  def matches?(response)
    case response
    when Nokogiri::XML::Node
      @actual_html = response.to_html
      @actual_doc  = Nokogiri::HTML.fragment(@actual_html)
    else
      @actual_html = response
      @actual_doc  = Nokogiri::HTML.fragment(response)
    end

    equivalent?
  end

  # @return [String] description of this matcher
  def description
    "match HTML against #{@expected_html}"
  end

  def failure_message
    "expected #{@expected_html} but it was #{@actual_html}"
  end

  def equivalent?
    diff.empty?
  end

  def diff
    @diff ||= CompareXML.equivalent?(@expected_doc, @actual_doc, **@options)
  end
end

module RSpec
  module Matchers
    def match_html(expected_html, **)
      HTMLMatcher.new(expected_html, **)
    end
  end
end

# frozen_string_literal: true

class Image < Asset
  dragonfly_accessor :data, app: :image

  delegate :width, :height, to: :data

  def url(*args)
    opt  = args.extract_options!
    size = opt[:size]
    size = args.shift if args.first.is_a?(String)
    path = "/#{self.class.to_s.tableize}/#{to_param}.#{data.ext}"
    return path if size.blank?

    width, height = size.match(/([0-9]*)x([0-9]*)/).to_a.drop 1
    "#{path}/?width=#{width}&height=#{height}"
  end
end

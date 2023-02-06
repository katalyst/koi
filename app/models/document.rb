# frozen_string_literal: true

class Document < Asset
  dragonfly_accessor :data, app: :file

  def url(*_args)
    "/#{self.class.to_s.tableize}/#{to_param}.#{data.ext}"
  end
end

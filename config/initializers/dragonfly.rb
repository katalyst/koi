require 'dragonfly/rails/images'

class Dragonfly::ActiveModelExtensions::Attachment

  def document?
    /pdf|xlsx?|docx?|txt|rtf/i === ext || ! image?
  end

end

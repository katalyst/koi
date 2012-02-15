Hash.class_eval do

  def merge_html(source)
    dup.merge_html!(source)
  end

  def merge_html!(source)
    merge! source do |k, t, s|
  	  case k
      when :class then "#{t} #{s}"
      when :style then "#{t};#{s}"
      else s
      end
  	end
  end

end

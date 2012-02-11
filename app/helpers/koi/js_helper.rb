module Koi::JsHelper

  # Description:
  #
  #   Converts the data to JSON and makes it available to JavaScript
  #   through the 'jsData' object.
  #
  # Usage:
  #
  #   <% js_data :my_variable, 'value' %>
  #
  #   <script>
  #     window.alert(jsData.myVariable);
  #   </script>
  #
  def js_data(name=nil, data=nil)
    @js_data ||= {}
    if name.blank?
      javascript_tag("var jsData = #{@js_data.to_json};")
    else
      @js_data[name.to_s.camelize(:lower)] = data
    end
  end

  def var(hash)
    assigns = hash.map{ |key, value| "#{key} = #{value.to_json}" }
    javascript_tag "var #{assigns.join ", "};"
  end

end

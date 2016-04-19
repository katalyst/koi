class <%= class_name %>Mailer < ActionMailer::Base

  def <%= singular_name %>_created(<%= model_path %>_id)
    @<%= model_path %> = <%= class_name %>.find(<%= model_path %>_id)
    mail subject: "<%= class_name %> Created",
         from: Figaro.env.no_reply_address,
         to: <%= class_name %>.setting(:<%= singular_name %>_emails, Figaro.env.default_to_address,
                role: "Admin", field_type: "text")
                .split(",").collect(&:strip)
  end

end

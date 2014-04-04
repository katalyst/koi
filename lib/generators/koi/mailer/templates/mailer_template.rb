class <%= class_name %>Mailer < ActionMailer::Base

  def <%= singular_name %>_created(<%= model_path %>_id)
    @<%= model_path %> = <%= class_name %>.find(<%= model_path %>_id)
    mail subject: "<%= class_name %> Created",
         from: "no-reply@katalyst.com.au",
         to: <%= class_name %>.setting(:<%= singular_name %>_emails, "admin@katalyst.com.au",
                role: "Admin", field_type: "text")
                .split(",").collect(&:strip)
  end

end

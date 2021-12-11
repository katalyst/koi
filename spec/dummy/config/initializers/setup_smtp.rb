mock_smtp_indicator = Rails.root + 'tmp/mock_smtp.txt'

if mock_smtp_indicator.exist?
  ActionMailer::Base.smtp_settings = {
    address: 'localhost',
    port: 1025,
    domain: 'katalyst.com.au'
  }
elsif Rails.env.production?
  ActionMailer::Base.smtp_settings = {
    address: 'smtp.mandrillapp.com',
    port: '587',
    authentication: :plain,
    user_name: ENV["MANDRILL_USERNAME"],
    password: ENV["MANDRILL_PASSWORD"]
  }
else
  ActionMailer::Base.smtp_settings = {
    user_name: ENV["MAILTRAP_USERNAME"],
    password: ENV["MAILTRAP_PASSWORD"],
    address: 'mailtrap.io',
    domain: 'mailtrap.io',
    port: '2525',
    authentication: :cram_md5,
    enable_starttls_auto: true
  }
end

# Only loads the Mock SMTP settings if tmp/mock_smtp.txt is present
#
# aliases for your bashrc/zshrc to make life easier
# alias mtd='touch tmp/mock_smtp.txt'
# alias mrd='rm tmp/mock_smtp.txt'

mock_smtp_indicator = Rails.root + 'tmp/mock_smtp.txt'

if mock_smtp_indicator.exist?
  ActionMailer::Base.smtp_settings = {
    :address => "localhost",
    :port => 1025,
    :domain => "katalyst.com.au"
  }
else
  ActionMailer::Base.smtp_settings = {
    :address => "smtp.sendgrid.net",
    :port => '25',
    :domain => "katalyst.com.au",
    :authentication => :plain,
    :user_name => "CONSULT WIKI",
    :password => "CONSULT WIKI"
  }
end

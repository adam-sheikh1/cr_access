class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('MAILER_SENDER_ADDRESS', 'no-reply@craccess.com')
  layout 'mailer'
end

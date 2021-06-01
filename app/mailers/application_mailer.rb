class ApplicationMailer < ActionMailer::Base
  helper :application

  default from: ENV.fetch('MAILER_SENDER_ADDRESS', 'no-reply@craccess.com')
  layout 'mailer'
end

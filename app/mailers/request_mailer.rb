class RequestMailer < ApplicationMailer
  def notify(request_id)
    @request = ShareRequest.find(request_id)
    @recipient = @request.recipient

    I18n.with_locale(locale) do
      mail to: @recipient.email, subject: 'Vaccination Records'
    end
  end
end

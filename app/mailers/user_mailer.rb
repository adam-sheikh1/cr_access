class UserMailer < ApplicationMailer
  def send_2fa_mail(user_id)
    @user = User.find(user_id)

    I18n.with_locale(locale) do
      mail to: @user.email, subject: '2FA Code'
    end
  end
end

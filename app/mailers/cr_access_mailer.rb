class CrAccessMailer < ApplicationMailer
  def share_data(user_id, cr_ids)
    @user = User.find(user_id)
    @cr_data_users = CrDataUser.where(id: cr_ids)

    I18n.with_locale(locale) do
      mail to: @user.email, subject: 'Data Sharing Invitation'
    end
  end
end

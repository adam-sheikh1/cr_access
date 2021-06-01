class CrAccessMailer < ApplicationMailer
  def share_data(user_id, cr_ids)
    @user = User.find(user_id)
    @cr_data_users = CrDataUser.where(id: cr_ids)

    I18n.with_locale(locale) do
      mail to: @user.email, subject: 'Data Sharing Invitation'
    end
  end

  def second_dose_reminder(cr_access_id)
    @cr_access_data = CrAccessData.find(cr_access_id)

    I18n.with_locale(locale) do
      mail to: @cr_access_data.email, subject: 'Second Dose Reminder'
    end
  end
end

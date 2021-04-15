class CrGroupMailer < ApplicationMailer
  def invite_cr_user(cr_access_id, group_id)
    @cr_access = CrAccessData.find(cr_access_id)
    @group = CrGroup.find(group_id)

    I18n.with_locale(locale) do
      mail to: @cr_access.email, subject: 'Group Invitation'
    end
  end
end

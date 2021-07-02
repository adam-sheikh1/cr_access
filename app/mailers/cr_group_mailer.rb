class CrGroupMailer < ApplicationMailer
  def invite_cr_user(cr_access, cr_access_group)
    @cr_access = cr_access
    @cr_access_group = cr_access_group
    @cr_group = @cr_access_group.cr_group

    I18n.with_locale(locale) do
      mail to: @cr_access.email, subject: 'Group Invitation'
    end
  end
end

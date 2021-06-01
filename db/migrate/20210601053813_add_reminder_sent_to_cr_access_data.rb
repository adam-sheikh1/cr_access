class AddReminderSentToCrAccessData < ActiveRecord::Migration[6.1]
  def change
    add_column :cr_access_data, :second_dose_reminder_date, :date
    add_column :cr_access_data, :reminder_sent_at, :datetime
    add_column :cr_access_data, :second_dose_date, :date
  end
end

require 'sidekiq-scheduler'

class SecondDoseReminderJob
  include Sidekiq::Worker

  sidekiq_options retry: 5, queue: 'default'

  def perform
    CrAccessData.second_dose_reminder.find_each do |cr_data|
      CrAccessMailer.second_dose_reminder(cr_data.id).deliver_later

      cr_data.update_columns(reminder_sent_at: DateTime.now)
    end
  end
end

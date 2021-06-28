class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def wrap_transaction(&block)
    ActiveRecord::Base.transaction(&block)
  end

  def validate_max_invites
    return if current_user.invites_sent_today < MAX_INVITES

    redirect_back fallback_location: root_path, alert: 'You have crossed the maximum number of allowed invites for today'
  end

  def increment_invites
    current_user.increment_invites_sent
  end
end

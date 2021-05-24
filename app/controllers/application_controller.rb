class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def wrap_transaction(&block)
    ActiveRecord::Base.transaction(&block)
  end
end

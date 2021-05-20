class HomeController < ApplicationController
  before_action :set_cr_access_data

  def index
    @qr_code = @cr_access.generate_qr_code if @cr_access.present?
    @fv_code = @cr_access.fv_code
  end

  private

  def set_cr_access_data
    @cr_access = current_user.primary_cr_data
  end
end

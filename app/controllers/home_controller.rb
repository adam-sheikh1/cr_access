class HomeController < ApplicationController
  before_action :set_cr_access_data

  def index
    @qr_code = @cr_access.generate_qr_code if @cr_access.present?
    @fv_code = @cr_access.fv_code
  end

  private

  def set_cr_access_data
    @cr_data_user = current_user.primary_data
    @cr_access = @cr_data_user.cr_access_data.fetch_data if @cr_data_user
  end
end

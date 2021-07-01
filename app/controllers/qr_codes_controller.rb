class QrCodesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[verify]

  before_action :set_qr_code, only: %i[refreshed_code]

  layout 'cr_access'

  def verify
    @qr_code = QrCode.find_by_code(params[:code])
    @codeable = @qr_code.codable_data if @qr_code
    @primary_data = current_user&.primary_cr_data
  end

  def refreshed_code
    @qr_code.refresh_code!

    render json: { image: @qr_code.image_string }
  end

  private

  def set_qr_code
    @qr_code = QrCode.find(params[:id])
  end
end

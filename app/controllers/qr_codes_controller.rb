class QrCodesController < ApplicationController
  before_action :set_qr_code, only: %i[refreshed_code]

  def verify
    @qr_code = QrCode.find_by_code(params[:code])
    @codeable = @qr_code.codeable if @qr_code
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

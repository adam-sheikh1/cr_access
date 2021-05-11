module QrCodeHelper
  def qr_code_image(qr_code, klass: '')
    image_tag qr_code.image_string, class: klass, data: { time_remaining: qr_code.remaining_time, qr_code_target: 'image', refresh_url: refreshed_code_qr_code_path(qr_code), refresh_interval: QrCode::TTL }
  end
end

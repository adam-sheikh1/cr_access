module QrCodeable
  extend ActiveSupport::Concern

  included do
    has_one :qr_code, as: :codeable, dependent: :destroy
  end

  def generate_qr_code
    return qr_code if qr_code.present? && !qr_code.expired?
    return qr_code.refresh_code! if qr_code&.expired?

    create_qr_code
  end
end

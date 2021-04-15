class QrCode < ApplicationRecord
  include Encodable

  belongs_to :codeable, polymorphic: true
  after_create :refresh_code!

  TTL = 5.minutes.to_i.freeze

  def refresh_code!
    exp = Time.now.to_i + TTL

    update(code: encoded_token(payload: { id: id, exp: exp }))
    self
  end

  def image_string
    ['data:image/jpeg;base64', Base64.encode64(RQRCode::QRCode.new(UrlHelpers.verify_qr_codes_url(code: code)).as_png(size: 240).to_s)].join(',')
  end

  def remaining_time
    [0, (self.class.decoded_data(code)&.fetch('exp').to_i - Time.now.to_i)].max
  end

  def expired?
    remaining_time.zero?
  end

  def self.find_by_code(code)
    find_by(id: decoded_data(code)&.fetch('id'))
  end

  def cr_group?
    codeable_type == CrGroup.name
  end

  def cr_access?
    codeable_type == CrAccessData.name
  end
end

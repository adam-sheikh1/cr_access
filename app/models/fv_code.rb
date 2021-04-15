class FvCode < ApplicationRecord
  belongs_to :fv_codable, polymorphic: true

  validates_uniqueness_of :code, allow_nil: true

  after_create :generate_code

  scope :cr_access, -> { where(fv_codable_type: CrAccessData.name) }

  def cr_group?
    fv_codable_type == CrGroup.name
  end

  def cr_access?
    fv_codable_type == CrAccessData.name
  end

  def generate_qr_code
    return unless cr_group? || cr_access?
    return fv_codable.generate_qr_code if cr_access?

    fv_codable.cr_access_data.map(&:generate_qr_code)
  end

  private

  def generate_code
    code = SecureRandom.alphanumeric(10).upcase
    code = SecureRandom.alphanumeric(10).upcase while FvCode.find_by(code: code).present?
    update(code: code)
  end
end

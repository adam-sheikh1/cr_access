class VaccinationRecord < ApplicationRecord
  ATTR_ACCESSORS = %i[clinic_name clinic_location dose_volume dose_volume_units lot_number manufacturer_name
                      reaction route site vaccination_date vaccine_name vaccine_expiration_date].freeze
  attr_accessor(*ATTR_ACCESSORS)

  belongs_to :cr_access_data

  has_many :vaccination_users, dependent: :destroy
  has_many :users, through: :vaccination_users
  has_many :request_vaccinations, dependent: :destroy
  has_many :share_requests, through: :request_vaccinations

  def vaccination_date=(date)
    @vaccination_date = date if date.is_a?(Date)
    @vaccination_date = date.to_date rescue nil if date.is_a?(String)
  end

  def self.by_cr_access_data(cr_access)
    vaccination_list = cr_access.vaccination_records_accessor(reload: true)
    vaccination_list.select { |vaccination| vaccination.id.in? ids }
  end
end

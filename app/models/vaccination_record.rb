class VaccinationRecord < ApplicationRecord
  belongs_to :cr_access_data

  has_many :vaccination_users, dependent: :destroy
  has_many :users, through: :vaccination_users
  has_many :request_vaccinations, dependent: :destroy
  has_many :share_requests, through: :request_vaccinations

  scope :by_cr_access_data, -> (cr_data) { where(cr_access_data: cr_data) }
end

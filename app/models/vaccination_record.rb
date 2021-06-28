class VaccinationRecord < ApplicationRecord
  belongs_to :cr_access_data

  has_many :vaccination_users, dependent: :destroy
  has_many :users, through: :vaccination_users
end

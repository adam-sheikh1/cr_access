class VaccinationUser < ApplicationRecord
  belongs_to :vaccination_record
  belongs_to :user

  validates_uniqueness_of :user_id, scope: [:vaccination_record_id]
end

class RequestVaccination < ApplicationRecord
  belongs_to :vaccination_record
  belongs_to :share_request
end

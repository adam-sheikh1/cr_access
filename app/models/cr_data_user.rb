class CrDataUser < ApplicationRecord
  belongs_to :user
  belongs_to :cr_access_data
end

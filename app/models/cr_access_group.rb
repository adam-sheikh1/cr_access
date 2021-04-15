class CrAccessGroup < ApplicationRecord
  belongs_to :cr_group
  belongs_to :cr_access_data

  validates_uniqueness_of :cr_group_id, scope: :cr_access_data_id
end

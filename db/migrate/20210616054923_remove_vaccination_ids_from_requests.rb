class RemoveVaccinationIdsFromRequests < ActiveRecord::Migration[6.1]
  def up
    remove_column :share_requests, :vaccination_record_ids
  end

  def down
    add_column :share_requests, :vaccination_record_ids, :text, array: true
  end
end

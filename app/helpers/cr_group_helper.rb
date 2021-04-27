module CrGroupHelper
  def group_type_options
    CrGroup::TYPES.deep_transform_keys { |k| k.to_s.humanize }.to_a
  end

  def cr_access_options
    current_user.cr_access_data.map { |data| [data.full_name, data.id] }
  end

  def cr_status(cr_data)
    return cr_data.cr_access_data.vaccination_status.titleize if cr_data.accepted?

    'Pending'
  end
end

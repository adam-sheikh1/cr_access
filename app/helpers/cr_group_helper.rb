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

  def sharing_type_options
    [%w[Phone phone], %w[Email email], ['Cr Access#', 'fv_code']]
  end

  def access_level_options
    CrAccessGroup.access_levels.deep_transform_keys(&:titleize)
  end
end

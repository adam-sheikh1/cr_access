module CrGroupHelper
  def group_type_options
    CrGroup::TYPES.deep_transform_keys { |k| k.to_s.humanize }.to_a
  end

  def cr_access_options
    current_user.cr_access_data.map { |data| [data.full_name, data.id] }
  end

  def cr_status(cr_data)
    cr_data.accepted? && cr_data.cr_access_data.vaccination_status.to_s.titleize || PENDING.titleize
  end

  def sharing_type_options
    [[PHONE.titleize, PHONE], [EMAIL.titleize, EMAIL], ['CRAccess#', FV_CODE]]
  end

  def share_info_options
    sharing_type_options[0..1]
  end

  def access_level_options
    CrAccessGroup.access_levels.deep_transform_keys(&:titleize)
  end
end

module CrAccessHelper
  def cr_access_url(cr_access_data)
    return cr_access_index_path if cr_access_data.new_record?

    cr_access_path(cr_access_data)
  end

  def qr_code_class(cr_access_data)
    'non-vaccinated' unless cr_access_data.fully_vaccinated?
  end
end

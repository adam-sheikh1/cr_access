module VaccinationHelper
  def checkbox_name(vaccine)
    ['vaccine', vaccine.id].join('_')
  end

  def indexed_id(name, index)
    [name, index].join('_')
  end

  def field_with_errors(form, name, required: false, data: {})
    [
      form.text_field(name, class: 'form-control', required: required,
                            autocomplete: 'off', data: data),
      error_tag(form, name)
    ].join(' ').html_safe
  end

  def select_with_errors(form, name, options, required: false)
    [
      form.select(name, options, { include_blank: 'Select' },
                  { class: 'form-control', required: required, autocomplete: 'off' }),
      error_tag(form, name)
    ].join(' ').html_safe
  end

  def error_tag(form, name)
    content_tag(:small, form.object.errors[name].reject(&:blank?).join(', '), class: 'text-danger ml-1')
  end

  def vaccine_selected?(id)
    params[:ids]&.include?(id.to_s)
  end

  def relationship_options
    ShareRequest::RELATIONSHIPS.keys.map { |k| [ShareRequest::RELATIONSHIPS[k], k] }
  end
end

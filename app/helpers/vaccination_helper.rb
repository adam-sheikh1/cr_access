module VaccinationHelper
  def checkbox_name(vaccine)
    ['vaccine', vaccine.id].join('_')
  end

  def indexed_id(name, index)
    [name, index].join('_')
  end

  def field_with_errors(form, name, index, required: false)
    [
      form.text_field(name, id: indexed_id(name, index), class: 'form-control', required: required, autocomplete: 'off'),
      content_tag(:small, form.object.errors[name].reject(&:blank?).join(', '), class: 'text-danger ml-1')
    ].join(' ').html_safe
  end

  def select_with_errors(form, name, options, index, required: false)
    [
      form.select(name, options, { include_blank: 'Select' }, { id: indexed_id(name, index), class: 'form-control', required: required, autocomplete: 'off' }),
      content_tag(:small, form.object.errors[name].reject(&:blank?).join(', '), class: 'text-danger ml-1')
    ].join(' ').html_safe
  end

  def vaccine_selected?(id)
    params[:ids]&.include?(id.to_s)
  end

  def relationship_options
    VaccinationShare::RELATION_SHIPS.deep_transform_keys { |k| k.to_s.humanize }.to_a
  end
end

class DatePickerInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    merged_input_html_options = input_html_options.merge(type: 'date', placeholder: 'yyyy/mm/dd')
    merged_input_html_options[:max] ||= '9999-12-31'

    merged_input_html_options[:data] ||= {}
    merged_input_html_options[:data][:can_type] = false

    merged_input_options = merge_wrapper_options(merged_input_html_options, wrapper_options)

    @builder.text_field(attribute_name, merged_input_options)
  end
end

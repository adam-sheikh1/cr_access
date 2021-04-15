module ApplicationHelper
  def flash_type(type)
    {
      'alert' => 'danger',
      'notice' => 'success'
    }.fetch(type, 'info')
  end
end

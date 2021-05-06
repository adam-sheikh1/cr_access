module ApplicationHelper
  def flash_type(type)
    {
      'alert' => 'danger',
      'notice' => 'success'
    }.fetch(type, 'info')
  end

  def active_class(url)
    'active' if url == request.path
  end
end

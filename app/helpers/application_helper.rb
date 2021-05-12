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

  def formatted_date(date)
    date.strftime('%m/%d/%y') rescue nil
  end
end

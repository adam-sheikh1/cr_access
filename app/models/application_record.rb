class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  self.implicit_order_column = :created_at

  def humanize_enum(enum_name)
    return unless send(enum_name)

    I18n.t("activerecord.attributes.#{self.class.name.underscore}.#{enum_name.to_s.pluralize}.#{send(enum_name)}",
           default: send(enum_name))
  end
end

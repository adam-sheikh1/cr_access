class UrlHelpers
  extend Rails.application.routes.url_helpers

  def self.url_options
    ActionMailer::Base.default_url_options
  end

  def self.optimize_routes_generation?
    true
  end
end

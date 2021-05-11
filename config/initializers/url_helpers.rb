class UrlHelpers
  class << self
    include Rails.application.routes.url_helpers

    def url_options
      ActionMailer::Base.default_url_options
    end
  end
end

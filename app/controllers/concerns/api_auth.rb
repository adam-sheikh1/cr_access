module ApiAuth
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user
  end

  def authenticate_user
    authenticate_or_request_with_http_basic do |username, password|
      username == ENV['API_AUTH_USERNAME'] && password == ENV['API_AUTH_PASSWORD']
    end
  end
end

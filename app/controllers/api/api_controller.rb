class Api::ApiController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include ApiAuth
  include ErrorsResponse
end

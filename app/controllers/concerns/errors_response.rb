module ErrorsResponse
  extend ActiveSupport::Concern

  included do
    rescue_from Errors::MissingParam, with: :bad_request
  end

  private

  def bad_request(exception)
    errors = {
      'errors': {
        'status': '400',
        'message': exception
      }
    }

    render json: errors, status: 400
  end
end

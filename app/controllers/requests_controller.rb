class RequestsController < ApplicationController
  before_action :set_request, only: %i[accept accept_request]
  before_action :set_request_by_token, only: %i[records]

  skip_before_action :authenticate_user!, only: %i[records]

  layout 'cr_access', only: 'records'

  def index
    @received_vaccinations = current_user.incoming_requests
  end

  def accept
    current_user.generate_2fa
  end

  def resend_2fa
    @generated = current_user.generate_2fa(resend: true)
  end

  def accept_request
    @verified = current_user.verify_2fa(params[:two_fa_code])
    return unless @verified

    @request.mark_accepted
  end

  def records
    @vaccinations = @request.vaccination_records
  end

  private

  def set_request
    @request = current_user.incoming_requests.find_by(id: params[:id])
    return if @request&.pending?

    redirect_to requests_path, alert: 'Invalid Access'
  end

  def set_request_by_token
    @request = ShareRequest.find_by_token(params[:token])
    return if @request.present?

    redirect_to new_user_session_path, alert: 'Token is invalid/expired'
  end
end

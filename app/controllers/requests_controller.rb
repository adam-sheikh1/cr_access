class RequestsController < ApplicationController
  before_action :set_request, only: %i[accept accept_request]

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

  private

  def set_request
    @request = current_user.incoming_requests.find_by(id: params[:id])
    return if @request&.pending?

    redirect_to requests_path, alert: 'Invalid Access'
  end
end

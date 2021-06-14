class VaccinationsController < ApplicationController
  before_action :set_cr_data, only: %i[index]

  def index
    @vaccinations = current_user.accessible_vaccinations.by_cr_access_data(@cr_data)
  end

  private

  def set_cr_data
    @cr_data = current_user.shared_cr_data.find_by(id: params[:cr_access_id])
    return if @cr_data.present?

    redirect_to vaccinations_user_path, alert: 'Invalid Access'
  end
end

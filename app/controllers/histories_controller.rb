class HistoriesController < ApplicationController
  before_action :set_vaccinations
  before_action :filter_ids, only: %i[share]
  before_action :fetch_vaccinations, only: %i[share]

  around_action :wrap_transaction, only: %i[share]

  def show
    @vaccination_shares = [VaccinationShare.new]
  end

  def share
    @vaccination_shares = VaccinationShare.init(share_vaccination_params, current_user)
    if VaccinationShare.valid?(@vaccination_shares) && VaccinationShare.share(@vaccination_shares, @vaccinations_to_share.ids)
      redirect_to history_path, notice: 'Shared Vaccination Records successfully'
    else
      @show_modal = true
      @ids = params[:ids]&.join(',')
      render :show
    end
  end

  private

  def set_vaccinations
    @vaccinations = current_user.vaccination_records
  end

  def share_vaccination_params
    params.permit(share: %i[data data_confirmation cr_access_no relation_ship])[:share]
  end

  def filter_ids
    params[:ids] = params[:ids].to_s.split(',')
  end

  def fetch_vaccinations
    @vaccinations_to_share = current_user.owned_vaccinations.where(id: params[:ids])
    redirect_to history_path, alert: 'Please select a vaccine to continue' if @vaccinations_to_share.blank?
  end
end

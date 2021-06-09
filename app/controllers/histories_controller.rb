class HistoriesController < ApplicationController
  before_action :set_vaccinations
  before_action :filter_ids, only: %i[share]
  before_action :fetch_vaccinations, only: %i[share]
  before_action :filter_params, only: %i[share]
  before_action :set_cr_access, only: %i[certificate show]
  before_action :set_request, only: %i[view_records]

  around_action :wrap_transaction, only: %i[share]

  def show
    @vaccination_share = current_user.share_requests.new
    @shared_vaccinations = current_user.share_requests.select(&:persisted?)
  end

  def share
    if current_user.update(share_vaccination_params)
      redirect_to history_path, notice: 'Shared Vaccination Records successfully'
    else
      @vaccination_share = current_user.share_requests.select(&:new_record?)
      @shared_vaccinations = current_user.share_requests.select(&:persisted?)
      @show_modal = true
      @ids = params[:ids]&.join(',')
      @cr_access = current_user.primary_cr_data
      render :show
    end
  end

  def view_records
    @vaccination_records = @request.vaccination_records
  end

  def certificate
    @first_dose = @cr_access.covid_vaccines.first
    @second_dose = @cr_access.covid_vaccines.second

    respond_to do |format|
      format.pdf do
        render pdf: 'certificate', page_size: 'A4',
               template: 'histories/certificate.html.erb',
               layout: 'pdf.html',
               orientation: 'Portrait',
               header: {
                 html: {
                   template: 'histories/certificate_header.html.erb'
                 }
               },
               footer: {
                 html: {
                   template: 'histories/certificate_footer.html.erb'
                 }
               }
      end
    end
  end

  private

  def set_vaccinations
    @vaccinations = current_user.vaccination_records
  end

  def share_vaccination_params
    params.require(:user).permit(share_requests_attributes: [:id, :relationship, :data, :data_confirmation, vaccination_record_ids: []])
  end

  def filter_ids
    params[:ids] = params[:ids].to_s.split(',')
  end

  def fetch_vaccinations
    @vaccinations_to_share = current_user.owned_vaccinations.where(id: params[:ids])
    redirect_to history_path, alert: 'Please select a vaccine to continue' if @vaccinations_to_share.blank?
  end

  def set_cr_access
    @cr_access = current_user.primary_cr_data
  end

  def filter_params
    params.dig(:user, :share_requests_attributes)&.each { |_a, b| b[:vaccination_record_ids] ||= params[:ids] }
  end

  def set_request
    @request = current_user.share_requests.find(params[:request_id])
  end
end

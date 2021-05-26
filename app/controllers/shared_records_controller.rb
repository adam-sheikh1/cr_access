class SharedRecordsController < ApplicationController
  before_action :set_cr_access_data, only: %i[show]

  def show
    @vaccinations = @cr_access_data.vaccination_records
  end

  private

  def set_cr_access_data
    @cr_access_group = current_user.accepted_cr_groups.find_by(id: params[:id])
    return redirect_to vaccinations_user_path, alert: 'Invalid Access' if @cr_access_group.blank?

    @cr_access_data = @cr_access_group.cr_access_data
  end
end

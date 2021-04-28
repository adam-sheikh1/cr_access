class CrAccessGroupsController < ApplicationController
  skip_before_action :authenticate_user!

  before_action :set_cr_access_group, only: %i[process_invite]
  before_action :decode_cr_access_group, only: %i[accept_invite]

  def accept_invite; end

  def process_invite
    if @cr_access_group.update(process_params)
      redirect_to vaccinations_user_path, notice: 'Successfully Accepted Invitation'
    else
      redirect_to vaccinations_user_path, alert: 'Something went wrong, please try again later.'
    end
  end

  def unlink
    if current_user.unlink_cr_access(@cr_access_data.id)
      redirect_to vaccinations_user_path, notice: 'Successfully unlinked.'
    else
      redirect_to vaccinations_user_path, alert: 'Error unlinking record, please try again later.'
    end
  end

  private

  def set_cr_access_group
    @cr_access_group = CrAccessGroup.find_by(id: params[:id])
    redirect_to root_path, alert: 'Invalid Access' if @cr_access_group.blank?
  end

  def decode_cr_access_group
    @cr_access_group = CrAccessGroup.find_by(id: CrAccessGroup.decoded_data(params[:token])&.fetch('cr_access_group_id'))
    redirect_to root_path, alert: 'Url Expired or Invalid' if @cr_access_group.blank?
  end

  def process_params
    params.require(:cr_access_group).permit(:access_level, :status)
  end
end

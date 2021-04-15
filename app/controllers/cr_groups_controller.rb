class CrGroupsController < ApplicationController
  before_action :set_group, except: %i[new create]
  before_action :validate_group, except: %i[new create]
  before_action :validate_owner, only: %i[invite send_invite remove]

  def show
    @cr_access_data = @group.cr_access_data
    @qr_code = @group.generate_qr_code
  end

  def invite
    @search = CrAccessData.ransack(params[:q])

    respond_to do |format|
      format.js do
        @cr_access_info = @search.result
      end
      format.html
    end
  end

  def send_invite
    if @group.invite(params[:fv_code])
      redirect_to @group, notice: 'Successfully sent invitation to user'
    else
      redirect_to [:invite, @group], alert: "Couldn't find any cr access"
    end
  end

  def new
    @group = CrGroup.new(user: current_user)
  end

  def edit; end

  def create
    @group = CrGroup.new(group_params)
    if @group.save
      redirect_to @group, notice: 'Successfully Create Group'
    else
      render :new
    end
  end

  def update
    if @group.update(group_params)
      redirect_to @group, notice: 'Successfully Updated Group'
    else
      render :edit
    end
  end

  def leave
    if @group.cr_access_groups.find_by(cr_access_data_id: current_user.primary_cr_data.id)&.destroy
      redirect_to vaccinations_user_path, notice: 'Successfully left group.'
    else
      redirect_to @group, alert: 'Error leaving group, please try again later.'
    end
  end

  def remove
    if @group.cr_access_groups.find_by(cr_access_data_id: params[:data_id])&.destroy
      redirect_to @group, notice: 'Successfully deleted from group.'
    else
      redirect_to @group, alert: 'Error deleting from group, please try again later.'
    end
  end

  private

  def set_group
    @group = CrGroup.find(params[:id])
  end

  def validate_group
    redirect_to vaccinations_user_path, alert: 'Invalid Access' unless @group.accessible_to?(current_user)
  end

  def validate_owner
    redirect_to vaccinations_user_path, alert: 'Invalid Access' unless @group.owner?(current_user)
  end

  def group_params
    params.require(:cr_group).permit(:name, :group_type).merge({ user_id: current_user.id })
  end
end

class CrGroupsController < ApplicationController
  include CrGroupHelper

  before_action :set_group, except: %i[new create]
  before_action :validate_group, except: %i[new create]
  before_action :validate_owner, only: %i[invite send_invite remove]
  before_action :validate_type, only: %i[send_invite]

  def show
    @cr_access_groups = @group.cr_access_groups_by_user(current_user).includes(:cr_access_data)
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
    if @group.invite(invite_params)
      redirect_to @group, notice: 'Successfully sent invitation to user'
    else
      redirect_to [:invite, @group], alert: "Couldn't find any CRAccess"
    end
  end

  def new
    @group = CrGroup.new(user: current_user)
    @groups = CrGroup.by_user(current_user).includes(:fv_code)
  end

  def edit; end

  def create
    @group = CrGroup.new(group_params)
    if @group.save
      redirect_to @group, notice: 'Successfully Create Group'
    else
      @groups = CrGroup.by_user(current_user).includes(:fv_code)
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

  def invite_params
    params.require(:invite).permit(:type, :data)
  end

  def validate_type
    return if invite_params[:type].in?(sharing_type_options.map(&:second))

    redirect_to invite_cr_group_path(@group), alert: 'Invalid Type'
  end
end

class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cr_access_data, only: %i[show edit]
  before_action :set_share_data, only: %i[send_info]

  def show
    @qr_code = @cr_access.generate_qr_code if @cr_access
  end

  def vaccinations
    @cr_access_info = CrDataUser.by_user(current_user).includes(:cr_access_data)
    @shared_cr_data = current_user.shared_cr_data.distinct
    @groups = CrGroup.by_user(current_user).includes(:fv_code)
  end

  def share_info; end

  def send_info
    if @cr_access_data.share_data(@user)
      redirect_to vaccinations_user_path, notice: 'Successfully sent email to accept info.'
    else
      redirect_to share_info_user_path, alert: 'Data already shared with user.'
    end
  end

  def accept_info
    if current_user.accept_info(params[:token])
      redirect_to vaccinations_user_path, notice: 'Successfully linked info into your profile'
    else
      redirect_to root_path, alert: 'Invalid Access'
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_with_password(user_params)
      bypass_sign_in(@user)
      redirect_to root_path, notice: 'Password successfully updated'
    else
      @cr_access = current_user.primary_cr_data
      render 'edit'
    end
  end

  def search_fv_code; end

  def search_fv
    @fv_code = FvCode.find_by(code: params[:code])
    @fv_code.generate_qr_code if @fv_code
  end

  def refresh_vaccinations
    current_user.cr_access_data.map(&:fetch_vaccination_history)

    redirect_back fallback_location: root_path, notice: 'Successfully refreshed vaccinations'
  end

  private

  def user_params
    params.require(:user).permit(:current_password, :password, :password_confirmation, :profile_picture, :first_name, :middle_name, :last_name)
  end

  def set_cr_access_data
    @cr_access = current_user.primary_cr_data
  end

  def invitation_params
    params.require(:cr_access).permit(:data, :type)
  end

  def set_share_data
    @user = User.find_by_invitation_params(invitation_params)
    return redirect_to share_info_user_path, alert: "Invalid #{invitation_params[:type].titleize}." if @user.blank?
    return redirect_to share_info_user_path, alert: 'Cannot share info to yourself.' if @user.id == current_user.id

    @cr_access_data = current_user.primary_cr_data
    redirect_to share_info_user_path, alert: 'Invalid Access.' if @cr_access_data.blank?
  end
end

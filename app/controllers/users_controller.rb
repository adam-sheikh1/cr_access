class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cr_access_data, only: %i[show]

  def show
    @qr_code = @cr_access.generate_qr_code if @cr_access
  end

  def vaccinations
    @cr_access_info = CrAccessData.by_user(current_user)
    @groups = CrGroup.by_user(current_user).includes(:fv_code)
  end

  def share_info; end

  def send_info
    @user = User.find_by_email(invitation_params[:email])
    return redirect_to share_info_user_path, alert: "Couldn't find user by email provided." if @user.blank?
    return redirect_to share_info_user_path, alert: 'Cannot share info to yourself.' if @user.id == current_user.id

    @cr_acccess_data = current_user.cr_access_data.where(id: invitation_params[:ids])
    return redirect_to share_info_user_path, alert: 'Please select info to send.' if @cr_acccess_data.blank?

    @cr_acccess_data.share_data(@user)
    redirect_to vaccinations_user_path, notice: 'Successfully send email to accept info.'
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
      redirect_to user_path(@user), notice: 'Password successfully updated'
    else
      render 'edit'
    end
  end

  def fv_code; end

  def search_fv_code; end

  def search_fv
    @fv_code = FvCode.find_by(code: params[:code])
    @fv_code.generate_qr_code if @fv_code
  end

  private

  def user_params
    params.require(:user).permit(:current_password, :password, :password_confirmation, :profile_picture)
  end

  def set_cr_access_data
    @cr_access = current_user.primary_cr_data
  end

  def invitation_params
    params.require(:cr_access).permit(:email, ids: [])
  end
end

class CrAccessController < ApplicationController
  skip_before_action :authenticate_user!, except: %i[show]

  before_action :set_cr_access_data, only: %i[show unlink]
  before_action :set_user, only: %i[update success]
  before_action :set_patient_data, only: %i[new]
  before_action :fetch_cr_data, only: %i[new]

  layout 'cr_access', except: [:show]
  layout 'application', only: [:show]

  def new
    if @cr_access_data.persisted?
      @cr_access_data.fetch_vaccination_history(@patient_data)
      return redirect_to success_cr_access_path(@user)
    end

    @user.assign_attributes(@patient_data.user_params)
    @cr_access_data.assign_attributes(@patient_data.patient_params)
  end

  def create
    @user = User.find_or_initialize_by(email: user_params[:email])

    @user.assign_attributes(user_params)
    @new_record = @user.new_record?
    @cr_access_data = @user.cr_access_data

    if @user.save
      redirect_to success_cr_access_path(@user, new_record: @new_record)
    else
      if @user.errors[:"cr_access_data.children.attributes"].present? || @user.errors[:"cr_access_data.attributes"].present?
        return redirect_back fallback_location: root_path, alert: @user.errors.full_messages.to_sentence
      end

      render :new
    end
  end

  def update
    @user.assign_attributes(user_params)
    @cr_access_data = @user.cr_access_data

    if @user.save
      redirect_to success_cr_access_path(@user)
    else
      render :new
    end
  end

  def success
    @cr_access_data = @user.cr_access_data
    @new_record = params[:new_record]
  end

  def show
    @qr_code = @cr_access_data.generate_qr_code
    @groups = @cr_access_data.cr_groups
    @vaccinations = @cr_access_data.vaccination_records
    @fv_code = @cr_access_data.fv_code
  end

  def unlink
    if current_user.unlink_cr_access(@cr_access_data.id)
      redirect_to vaccinations_user_path, notice: 'Successfully unlinked.'
    else
      redirect_to vaccinations_user_path, alert: 'Error unlinking record, please try again later.'
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :date_of_birth, :phone_number, :password,
                                 :password_confirmation, cr_access_data_attributes: CrAccessData.permitted_params)
  end

  def set_cr_access_data
    @cr_access_data = current_user.accepted_data.find_by(id: params[:id])
    redirect_to root_path, alert: 'Invalid Access' if @cr_access_data.blank?
  end

  def set_patient_data
    @patient_data = ImportPatientData.new(params[:token])
    redirect_to new_user_session_path, alert: 'Invalid Access' if @patient_data.patient_params.blank?
  end

  def fetch_cr_data
    @cr_access_data = CrAccessData.find_or_initialize_by(prepmod_patient_id: @patient_data.patient_params[:prepmod_patient_id])
    if @cr_access_data.persisted? && !@cr_access_data.prepmod_user&.persisted?
      return redirect_to new_user_session_path, alert: 'Invalid Access'
    end

    @user = @cr_access_data.prepmod_user || @cr_access_data.build_prepmod_data.build_user
  end
end
